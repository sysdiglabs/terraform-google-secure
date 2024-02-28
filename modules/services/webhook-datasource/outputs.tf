output "push_endpoint" {
  value       = google_pubsub_subscription.ingestion_topic_push_subscription.push_config[0].push_endpoint
  description = "Push endpoint towards which the POST request will be directed"
}

output "ingestion_pubsub_topic_name" {
  value       = google_pubsub_topic.ingestion_topic.name
  description = "PubSub ingestion topic that will hold all the AuditLogs coming from the specified project"
}

output "ingestion_sink_name" {
  value       = var.is_organizational ? google_logging_organization_sink.ingestion_sink[0].name : google_logging_project_sink.ingestion_sink[0].name
  description = "Project/Organization sink to direct the AuditLogs towards a dedicated PubSub topic"
}

output "ingestion_push_subscription_name" {
  value       = google_pubsub_subscription.ingestion_topic_push_subscription.name
  description = "Push Subscription that will POST the AuditLogs collected from the project towards Sysdig's backend"
}

output "workload_identity_pool_id" {
  value       = google_iam_workload_identity_pool.ingestion_auth_pool.workload_identity_pool_id
  description = "Id of Workload Identity Pool for authenticating to GCP to access data ingestion resources"
}

output "workload_identity_pool_provider_id" {
  value       = google_iam_workload_identity_pool_provider.ingestion_auth_pool_provider.workload_identity_pool_provider_id
  description = "Id of Workload Identity Pool Provider for authenticating to GCP to access data ingestion resources"
}

output "workload_identity_project_number" {
  value       = data.google_project.project.number
  description = "GCP project number"
}

output "service_account_email" {
  value       = google_service_account.push_auth.email
  description = "email of the Service Account created"
}
