output "workload_identity_pool_id" {
  value       = google_iam_workload_identity_pool.onboarding_auth_pool.workload_identity_pool_id
  description = "Id of Workload Identity Pool for authenticating to GCP to access data onboarding resources"
}

output "workload_identity_pool_provider_id" {
  value       = google_iam_workload_identity_pool_provider.onboarding_auth_pool_provider.workload_identity_pool_provider_id
  description = "Id of Workload Identity Pool Provider for authenticating to GCP to access data onboarding resources"
}

output "workload_identity_project_number" {
  value       = data.google_project.project.number
  description = "GCP project number"
}

output "service_account_email" {
  value       = google_service_account.onboarding_auth.email
  description = "email of the Service Account created"
}

output "project_id" {
  value       = var.project_id
  description = "Project ID in which secure-for-cloud onboarding resources are created. For organizational installs it is the Management Project ID selected during install"
}

output "sysdig_secure_project_id" {
  value       = sysdig_secure_cloud_auth_account.google_account.id
  description = "ID of the Sysdig Cloud Account created"
}

output "is_organizational" {
  value       = var.is_organizational
  description = "Boolean value to indicate if secure-for-cloud is deployed to an entire GCP organization or not"
}
