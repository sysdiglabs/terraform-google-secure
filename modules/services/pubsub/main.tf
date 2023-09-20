provider "google" {
  project = var.project_id
  region  = "us-central1"
}

########################################################################################
# The pubsub module takes care of provisioning the necessary resources to make Sysdig's
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

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_pubsub_topic" "cloudingestion-topic" {
  name = "cloudingestion-topic"

  # TODO(jojo): Verify which labels we need
  labels = {
    foo = "bar"
  }

  project                    = var.project_id
  message_retention_duration = "86600s"
}

resource "google_pubsub_topic" "deadletter-topic" {
  name = "dl-${google_pubsub_topic.cloudingestion-topic.name}"

  project                    = var.project_id
  message_retention_duration = "86600s"
}

resource "google_service_account" "push-auth" {
  account_id   = "sysdig-push-auth"
  display_name = "Push Auth Service Account"
}

resource "google_service_account_iam_binding" "push-auth-binding" {
  service_account_id = google_service_account.push-auth.name
  role               = "roles/iam.serviceAccountTokenCreator"

  members = [
    "serviceAccount:${google_service_account.push-auth.email}",
  ]
}

resource "google_pubsub_subscription" "cloudingestion-push-subscription" {
  name  = "${google_pubsub_topic.cloudingestion-topic.name}-push-subscription"
  topic = google_pubsub_topic.cloudingestion-topic.name

  ack_deadline_seconds = 60

  message_retention_duration = "604800s"

  # TODO(jojo): Verify which labels we need
  labels = {
    foo = "bar"
  }

  push_config {
    push_endpoint = var.push_endpoint

    attributes = {
      x-goog-version = "v1"
    }

    oidc_token {
      service_account_email = google_service_account.push-auth.email
      audience              = "sysdig-secure"
    }
  }

  # NOTE(jojo): These are the default values, for now
  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.deadletter-topic.id
    max_delivery_attempts = 5
  }
}

resource "google_logging_project_sink" "cloudingestion-sink" {
  name        = "${google_pubsub_topic.cloudingestion-topic.name}-sink"
  description = "Sysdig sink to direct the AuditLogs to the PubSub topic used for data gathering"

  # NOTE(jojo): Our preferred destination is a PubSub topic
  destination = "pubsub.googleapis.com/projects/${var.project_id}/topics/${google_pubsub_topic.cloudingestion-topic.name}"

  filter = "protoPayload.@type = \"type.googleapis.com/google.cloud.audit.AuditLog\""

  unique_writer_identity = true
}

resource "google_pubsub_topic_iam_member" "writer" {
  project = google_pubsub_topic.cloudingestion-topic.project
  topic   = google_pubsub_topic.cloudingestion-topic.name
  role    = "roles/pubsub.publisher"
  member  = google_logging_project_sink.cloudingestion-sink.writer_identity
}

resource "google_project_iam_audit_config" "project" {
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
