output "project_id" {
  value       = data.google_project.project.id
  description = "GCP Project Identifier"
}

output "push_subscription_service_account" {
  value       = google_service_account.push_auth.name
  description = "Service Account used to send POST messages, a KMS key needs to be manually added in order to properly authenticate the requests at Sysdig's side"
}

output "push_endpoint" {
  value       = google_pubsub_subscription.ingestion_topic_push_subscription.push_config.push_endpoint
  description = "Push endpoint towards which the POST request will be directed"
}
