output "project_id" {
  value       = var.project_id
  description = "Project ID in which secure-for-cloud onboarding resources are created. For organizational installs it is the Management Project ID selected during install"
}

output "sysdig_secure_account_id" {
  value       = sysdig_secure_cloud_auth_account.google_account.id
  description = "ID of the Sysdig Cloud Account created"
}

output "is_organizational" {
  value       = var.is_organizational
  description = "Boolean value to indicate if secure-for-cloud is deployed to an entire GCP organization or not"
}

output "organization_domain" {
  value       = var.organization_domain
  description = "Organization domain. e.g. sysdig.com"
}

output "include_folders" {
  description = "folders to include for organization"
  value       = var.include_folders
}

output "exclude_folders" {
  description = "folders to exclude for organization"
  value       = var.exclude_folders
}

output "include_projects" {
  description = "projects to include for organization"
  value       = var.include_projects
}

output "exclude_projects" {
  description = "projects to exclude for organization"
  value       = var.exclude_projects
}