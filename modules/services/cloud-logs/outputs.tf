output "sink_service_account" {
  value       = google_logging_project_sink.cloudingestion-sink.writer_identity
  description = "Writer identity of sink SA"
}

output "project_number" {
  value       = data.google_project.project.number
  description = "Writer identity of sink SA"
}
