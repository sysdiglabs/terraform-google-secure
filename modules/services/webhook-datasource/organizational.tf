#--------------#
# Organization #
#--------------#

data "google_organization" "org" {
  count  = var.is_organizational ? 1 : 0
  domain = var.organization_domain
}

#------------#
# Audit Logs #
#------------#
resource "google_organization_iam_audit_config" "audit_config" {
  count = var.is_organizational ? 1 : 0

  org_id  = data.google_organization.org[0].org_id
  service = "allServices"

  audit_log_config {
    log_type = "ADMIN_READ"
  }

  audit_log_config {
    log_type = "DATA_READ"
  }

  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

#------#
# Sink #
#------#

resource "google_logging_organization_sink" "ingestion_sink" {
  count = var.is_organizational ? 1 : 0

  name        = "${google_pubsub_topic.ingestion_topic.name}_sink"
  description = "Sysdig sink to direct the AuditLogs to the PubSub topic used for data gathering"
  org_id      = data.google_organization.org[0].org_id

  # NOTE: The target destination is a PubSub topic
  destination = "pubsub.googleapis.com/projects/${var.project_id}/topics/${google_pubsub_topic.ingestion_topic.name}"
  filter      = "protoPayload.@type = \"type.googleapis.com/google.cloud.audit.AuditLog\""

  # NOTE: The include_children attribute is set to true in order to ingest data
  # even from potential sub-organizations
  include_children = true
}

# creating custom role with organization-level permissions to access data ingestion resources
resource "google_organization_iam_custom_role" "custom_ingestion_auth_role" {
  count = var.is_organizational ? 1 : 0

  org_id      = data.google_organization.org[0].org_id
  role_id     = var.role_name
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

# adding custom role with organization-level permissions to the service account for auth
resource "google_organization_iam_member" "custom" {
  count = var.is_organizational ? 1 : 0

  org_id = data.google_organization.org[0].org_id
  role   = google_organization_iam_custom_role.custom_ingestion_auth_role[0].id
  member = "serviceAccount:${google_service_account.push_auth.email}"
}
