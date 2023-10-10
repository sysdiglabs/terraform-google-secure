output "push_endpoint" {
  value       = google_pubsub_subscription.ingestion_topic_push_subscription.push_config[0].push_endpoint
  description = "Push endpoint towards which the POST request will be directed"
}
