output "project_id" {
  value = var.project_id
}

output "project_number" {
  value = data.google_project.project.number
}

# note; duplicated on
# - module output values
# - sysdig_provider outputs for API

output "controller_service_account" {
  value = google_service_account.controller.email

  description = "Service Account (email) for Sysdig host Discovery to use"
}

# note; duplicated on
# - module output values
# - sysdig_provider outputs for API
output "workload_identity_pool_provider" {
  value = var.sysdig_backend != null ? google_iam_workload_identity_pool_provider.agentless[0].name : var.sysdig_account_id != null ? google_iam_workload_identity_pool_provider.agentless_gcp[0].name : null
  precondition {
    condition     = (var.sysdig_backend != null && var.sysdig_account_id == null) || (var.sysdig_backend == null && var.sysdig_account_id != null)
    error_message = "Cannot provide both sysdig_backend or sysdig_account_id"
  }

  description = "Workload Identity Pool Provider URL for Sysdig host Discovery to use"
}

output "json_payload" {
  value = jsonencode({
    "projectId"        = var.project_id
    "projectNumber"    = data.google_project.project.number
    "serviceAccount"   = google_service_account.controller.email
    "identityProvider" = var.sysdig_backend != null ? google_iam_workload_identity_pool_provider.agentless[0].name : var.sysdig_account_id != null ? google_iam_workload_identity_pool_provider.agentless_gcp[0].name : null
  })
  precondition {
    condition     = (var.sysdig_backend != null && var.sysdig_account_id == null) || (var.sysdig_backend == null && var.sysdig_account_id != null)
    error_message = "Cannot provide both sysdig_backend or sysdig_account_id"
  }

  description="Deprecated. JSON Payload to internally provision customer on Sysdig VM Host scan on Sysdig"
}
