output "project_id" {
  value = var.project_id
}

output "project_number" {
  value = data.google_project.project.number
}

output "controller_service_account" {
  value = google_service_account.lambda.email
}

output "workload_identity_pool_provider" {
  value = var.sysdig_backend != null ? google_iam_workload_identity_pool_provider.lambda[0].name : var.sysdig_account_id != null ? google_iam_workload_identity_pool_provider.lambda_gcp[0].name : null
  precondition {
    condition     = (var.sysdig_backend != null && var.sysdig_account_id == null) || (var.sysdig_backend == null && var.sysdig_account_id != null)
    error_message = "Cannot provide both sysdig_backend or sysdig_account_id"
  }
}

output "json_payload" {
  value = jsonencode({
    "projectId"        = var.project_id
    "projectNumber"    = data.google_project.project.number
    "serviceAccount"   = google_service_account.lambda.email
    "identityProvider" = var.sysdig_backend != null ? google_iam_workload_identity_pool_provider.lambda[0].name : var.sysdig_account_id != null ? google_iam_workload_identity_pool_provider.lambda_gcp[0].name : null
  })
  precondition {
    condition     = (var.sysdig_backend != null && var.sysdig_account_id == null) || (var.sysdig_backend == null && var.sysdig_account_id != null)
    error_message = "Cannot provide both sysdig_backend or sysdig_account_id"
  }
}
