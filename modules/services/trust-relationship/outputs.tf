output "service_account_email" {
  value       = google_service_account.sa.email
  description = "email address of the Service Account created (used to allow Sysdig Secure access)"
}

output "service_account_key" {
  value       = google_service_account_key.secure_service_account_key.private_key
  description = "Private Key of the Service Account created"
  sensitive   = true
}