resource "sysdig_secure_cloud_auth_account" "gcp_project_" {
  enabled       = true
  provider_id   = var.project_id
  provider_type = "PROVIDER_GCP"

  feature {
    seucre_agentless_scanning {
      enabled    = true
      components = ["COMPONENT_SERVICE_PRINCIPAL/secure-scanning"]
    }
  }

  component {
    type     = "COMPONENT_SERVICE_PRINCIPAL"
    instance = "secure-scanning"
    service_principal_metadata = jsonencode({
      # note; duplicated on
      # - module output values
      # - sysdig_provider outputs for API
      gcp = {
        authUri = var.sysdig_backend != null ? google_iam_workload_identity_pool_provider.agentless[0].name : var.sysdig_account_id != null ? google_iam_workload_identity_pool_provider.agentless_gcp[0].name : null
        clientEmail = google_service_account.controller.email
      }
    })
  }
  depends_on = [google_service_account.controller, var.sysdig_backend != null ? google_iam_workload_identity_pool_provider.agentless?google_iam_workload_identity_pool_provider.agentless_gcp]
}