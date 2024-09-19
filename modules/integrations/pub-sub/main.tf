#-----------------------------------------------------------------------------------------------------------------------------------------
# For Organizational installs, see organizational.tf.
# This module  takes care of provisioning the necessary resources to make Sysdig's backend able to ingest data from a
# single GCP project.
#
# Note: The alternative definitions for the organizational variant of this module are contained
# in organizational.tf. The only differences w.r.t. the standalone template is in using an
# organizational sink instead of a project-specific one, as well as enabling AuditLogs for
# all the projects that fall within the organization.
#-----------------------------------------------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------
# Fetch the data sources
#-----------------------------------------------------------------------------------------
data "sysdig_secure_trusted_cloud_identity" "trusted_identity" {
  cloud_provider = "gcp"
}

data "google_project" "project" {
  project_id = var.project_id
}

data "sysdig_secure_tenant_external_id" "external_id" {}

data "sysdig_secure_cloud_ingestion_assets" "assets" {}

#-----------------------------------------------------------------------------------------
# These locals indicate the suffix to create unique name for resources
#-----------------------------------------------------------------------------------------
locals {
  suffix    = var.suffix == null ? random_id.suffix[0].hex : var.suffix
  role_name = "SysdigIngestionAuthRole"
}


#-----------------------------------------------------------------------------------------------------------------------
# A random resource is used to generate unique Pub Sub name suffix for resources.
# This prevents conflicts when recreating a Pub Sub resources with the same name.
#-----------------------------------------------------------------------------------------------------------------------
resource "random_id" "suffix" {
  count       = var.suffix == null ? 1 : 0
  byte_length = 3
}

#-----------------------------------------------------------------------------------------
# Audit Logs
#-----------------------------------------------------------------------------------------
locals {
  # Data structure will be a map for each service, that can have multiple audit_log_config
  audit_log_config = { for audit in var.audit_log_config :
    audit["service"] => {
      log_config = audit["log_config"]
    }
  }
}

resource "google_project_iam_audit_config" "audit_config" {
  for_each = var.is_organizational ? {} : local.audit_log_config
  project  = var.project_id
  service  = each.key

  dynamic "audit_log_config" {
    for_each = each.value.log_config
    iterator = log_config
    content {
      log_type         = log_config.value.log_type
      exempted_members = log_config.value.exempted_members
    }
  }
}

#-----------------------------------------------------------------------------------------
# Ingestion Topic
#-----------------------------------------------------------------------------------------
resource "google_pubsub_topic" "ingestion_topic" {
  name                       = "ingestion_topic${local.suffix}"
  labels                     = var.labels
  project                    = var.project_id
  message_retention_duration = var.message_retention_duration
}

resource "google_pubsub_topic" "deadletter_topic" {
  name                       = "dl-${google_pubsub_topic.ingestion_topic.name}"
  project                    = var.project_id
  message_retention_duration = var.message_retention_duration
}

#-----------------------------------------------------------------------------------------
# Sink
#-----------------------------------------------------------------------------------------
resource "google_logging_project_sink" "ingestion_sink" {
  count       = var.is_organizational ? 0 : 1
  name        = "${google_pubsub_topic.ingestion_topic.name}_sink"
  description = "Sysdig sink to direct the AuditLogs to the PubSub topic used for data gathering"

  # NOTE: The target destination is a PubSub topic
  destination = "pubsub.googleapis.com/projects/${var.project_id}/topics/${google_pubsub_topic.ingestion_topic.name}"
  filter      = var.ingestion_sink_filter

  # Dynamic block to exclude logs from ingestion
  dynamic "exclusions" {
    for_each = var.exclude_logs_filter
    content {
      name        = exclusions.value.name
      description = exclusions.value.description
      filter      = exclusions.value.filter
      disabled    = exclusions.value.disabled
    }
  }

  # NOTE: Used to create a dedicated writer identity and not using the default one
  unique_writer_identity = true
}

resource "google_pubsub_topic_iam_member" "publisher_iam_member" {
  project = google_pubsub_topic.ingestion_topic.project
  topic   = google_pubsub_topic.ingestion_topic.name
  role    = "roles/pubsub.publisher"
  member  = var.is_organizational ? google_logging_organization_sink.ingestion_sink[0].writer_identity : google_logging_project_sink.ingestion_sink[0].writer_identity
}

#-----------------------------------------------------------------------------------------
# Push Subscription
#-----------------------------------------------------------------------------------------
resource "google_service_account" "push_auth" {
  account_id   = "sysdig-ingestion-${local.suffix}"
  display_name = "Sysdig Ingestion Push Auth Service Account"
  project      = var.project_id
}

resource "google_service_account_iam_binding" "push_auth_binding" {
  service_account_id = google_service_account.push_auth.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${google_service_account.push_auth.email}",
  ]
}

resource "google_pubsub_subscription" "ingestion_topic_push_subscription" {
  name                       = "${google_pubsub_topic.ingestion_topic.name}_push_subscription"
  topic                      = google_pubsub_topic.ingestion_topic.name
  labels                     = var.labels
  ack_deadline_seconds       = var.ack_deadline_seconds
  message_retention_duration = var.message_retention_duration
  project                    = var.project_id

  push_config {
    push_endpoint = data.sysdig_secure_cloud_ingestion_assets.assets.gcp_metadata.ingestionURL
    attributes = {
      x-goog-version = "v1"
    }
    oidc_token {
      service_account_email = google_service_account.push_auth.email
      audience              = "sysdig_secure"
    }
  }

  retry_policy {
    minimum_backoff = var.minimum_backoff
    maximum_backoff = var.maximum_backoff
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.deadletter_topic.id
    max_delivery_attempts = var.max_delivery_attempts
  }
}

#-----------------------------------------------------------------------------------------
# Configure Workload Identity Federation for auth
# See https://cloud.google.com/iam/docs/access-resources-aws
# -----------------------------------------------------------------------------------------

resource "google_iam_workload_identity_pool" "ingestion_auth_pool" {
  project                   = var.project_id
  workload_identity_pool_id = "sysdig-ingestion-${local.suffix}"
}

resource "google_iam_workload_identity_pool_provider" "ingestion_auth_pool_provider" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.ingestion_auth_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "sysdig-ingestion-${local.suffix}"
  display_name                       = "Sysdigcloud ingestion auth"
  description                        = "AWS identity pool provider for Sysdig Secure Data Ingestion resources"
  disabled                           = false

  attribute_condition = "attribute.aws_role==\"arn:aws:sts::${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id}:assumed-role/${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_role_name}/${data.sysdig_secure_tenant_external_id.external_id.external_id}\""

  attribute_mapping = {
    "google.subject"     = "assertion.arn",
    "attribute.aws_role" = "assertion.arn"
  }

  aws {
    account_id = data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id
  }
}

# creating custom role with project-level permissions to access data ingestion resources
resource "google_project_iam_custom_role" "custom_ingestion_auth_role" {
  count = var.is_organizational ? 0 : 1

  project     = var.project_id
  role_id     = "${local.role_name}${local.suffix}"
  title       = "Sysdigcloud Ingestion Auth Role"
  description = "A Role providing the required permissions for Sysdig Backend to read cloud resources created for data ingestion"
  permissions = [
    "pubsub.topics.get",
    "pubsub.topics.list",
    "pubsub.subscriptions.get",
    "pubsub.subscriptions.list",
    "logging.sinks.get",
    "logging.sinks.list",
  ]
}

# adding custom role with project-level permissions to the service account for auth
resource "google_project_iam_member" "custom" {
  count = var.is_organizational ? 0 : 1

  project = var.project_id
  role    = google_project_iam_custom_role.custom_ingestion_auth_role[0].id
  member  = "serviceAccount:${google_service_account.push_auth.email}"
}

# attaching WIF as a member to the service account for auth
resource "google_service_account_iam_member" "custom_auth" {
  service_account_id = google_service_account.push_auth.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.ingestion_auth_pool.workload_identity_pool_id}/attribute.aws_role/arn:aws:sts::${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id}:assumed-role/${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_role_name}/${data.sysdig_secure_tenant_external_id.external_id.external_id}"
}

# adding ciem role with permissions to the service account
resource "google_project_iam_member" "identity_mgmt" {
  for_each = var.is_organizational ? [] : toset(["roles/recommender.viewer", "roles/iam.serviceAccountViewer", "roles/iam.roleViewer", "roles/container.clusterViewer", "roles/compute.viewer"])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.push_auth.email}"
}

#-----------------------------------------------------------------------------------------------------------------------------------------
# Call Sysdig Backend to add the pub-sub integration to the Sysdig Cloud Account
#
# Note (optional): To ensure this gets called after all cloud resources are created, add
# explicit dependency using depends_on
#-----------------------------------------------------------------------------------------------------------------------------------------

resource "sysdig_secure_cloud_auth_account_component" "gcp_pubsub_datasource" {
  account_id = var.sysdig_secure_account_id
  type       = "COMPONENT_WEBHOOK_DATASOURCE"
  instance   = "secure-runtime"
  version    = "v0.1.0"
  webhook_datasource_metadata = jsonencode({
    gcp = {
      webhook_datasource = {
        pubsub_topic_name      = google_pubsub_topic.ingestion_topic.name
        sink_name              = var.is_organizational ? google_logging_organization_sink.ingestion_sink[0].name : google_logging_project_sink.ingestion_sink[0].name
        push_subscription_name = google_pubsub_subscription.ingestion_topic_push_subscription.name
        push_endpoint          = google_pubsub_subscription.ingestion_topic_push_subscription.push_config[0].push_endpoint
        routing_key            = data.sysdig_secure_cloud_ingestion_assets.assets.gcp_routing_key
      }
      service_principal = {
        workload_identity_federation = {
          pool_id          = google_iam_workload_identity_pool.ingestion_auth_pool.workload_identity_pool_id
          pool_provider_id = google_iam_workload_identity_pool_provider.ingestion_auth_pool_provider.workload_identity_pool_provider_id
          project_number   = data.google_project.project.number
        }
        email = google_service_account.push_auth.email
      }
    }
  })
}