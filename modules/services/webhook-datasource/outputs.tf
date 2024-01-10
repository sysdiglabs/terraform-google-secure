output "push_endpoint" {
  value       = google_pubsub_subscription.ingestion_topic_push_subscription.push_config[0].push_endpoint
  description = "Push endpoint towards which the POST request will be directed"
}

output "ingestion_pubsub_topic_name" {
  value       = google_pubsub_topic.ingestion_topic.name
  description = "PubSub ingestion topic that will hold all the AuditLogs coming from the specified project"
}

output "ingestion_sink_name" {
  value       = google_logging_project_sink.ingestion_sink.name
  description = "Project/Organization sink to direct the AuditLogs towards a dedicated PubSub topic"
}

output "ingestion_push_subscription_name" {
  value       = google_pubsub_subscription.ingestion_topic_push_subscription.name
  description = "Push Subscription that will POST the AuditLogs collected from the project towards Sysdig's backend"
}
