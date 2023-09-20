# TODO(jojo): Remove the provider declaration
provider "google" {
  project = var.project_id
  region  = "us-central1"
}

########################################################################################
# The cloud-logs module takes care of provisioning the necessary resources to make Sysdig's
# backend able to ingest data from a single GCP project.
#
# Before applying the changes defined in this module, the following operations need to
# be performed on the target GCP environment:
#   - Creating a GCP project
#   - Enabling the following APIs in the target environment (https://support.google.com/googleapi/answer/6158841?hl=en)
#     - Cloud Pub/Sub API
#     - Identity and Access Management (IAM) API
#     - IAM Service Account Credentials API
#
# Given that, this module will take care of enabling the AuditLogs for the selected
# project, direct them to a dedicated PubSub through a Sink and finally creating a Push
# Subscription that will send the data to Sysdig's backend. This module takes also care
# of creating the necessary service accounts along with the necessary policies to enable
# pushing logs to Sysdig's system.
########################################################################################


#------------#
# Audit Logs #
#------------#

resource "google_project_iam_audit_config" "audit_config" {
  project = var.project_id
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

resource "google_logging_project_sink" "ingestion_sink" {
  name        = "${google_pubsub_topic.ingestion_topic.name}_sink"
  description = "Sysdig sink to direct the AuditLogs to the PubSub topic used for data gathering"

  # NOTE: The target destination is a PubSub topic
  destination = "pubsub.googleapis.com/projects/${var.project_id}/topics/${google_pubsub_topic.ingestion_topic.name}"

  filter = "protoPayload.@type = \"type.googleapis.com/google.cloud.audit.AuditLog\""

  # NOTE: Used to create a dedicated writer identity and not using the default one
  unique_writer_identity = true
}

resource "google_pubsub_topic_iam_member" "publisher_iam_member" {
  project = google_pubsub_topic.ingestion_topic.project
  topic   = google_pubsub_topic.ingestion_topic.name
  role    = "roles/pubsub.publisher"
  member  = google_logging_project_sink.ingestion_sink.writer_identity
}

#-----------------#
# Ingestion topic #
#-----------------#

resource "google_pubsub_topic" "ingestion_topic" {
  name                       = "ingestion_topic"
  labels                     = var.labels
  project                    = var.project_id
  message_retention_duration = var.message_retention_duration
}

resource "google_pubsub_topic" "deadletter_topic" {
  name = "dl-${google_pubsub_topic.ingestion_topic.name}"

  project                    = var.project_id
  message_retention_duration = var.message_retention_duration
}

#-------------------#
# Push Subscription #
#-------------------#

resource "google_service_account" "push_auth" {
  account_id   = "ingestion_topic_push_auth"
  display_name = "Push Auth Service Account"
}

resource "google_service_account_iam_binding" "push_auth_binding" {
  service_account_id = google_service_account.push_auth.name
  role               = "roles/iam.serviceAccountTokenCreator"

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


  push_config {
    push_endpoint = var.push_endpoint

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

