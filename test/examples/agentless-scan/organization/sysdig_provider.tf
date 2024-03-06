provider "sysdig" {
  sysdig_secure_url       = "https://secure-staging.sysdig.com"
  sysdig_secure_api_token = "12124235"
}

resource "sysdig_secure_cloud_auth_account" "gcp_project" {
  enabled       = true
  provider_id   = "mytestproject"
  provider_type = "PROVIDER_GCP"

  feature {
    secure_agentless_scanning {
      enabled    = true
      components = ["COMPONENT_SERVICE_PRINCIPAL/secure-scanning"]
    }
  }

  component {
    type     = "COMPONENT_SERVICE_PRINCIPAL"
    instance = "secure-scanning"
    service_principal_metadata = jsonencode({
      gcp = {
        workload_identity_federation = {
          pool_provider_id = module.agentless_scan.workload_identity_pool_provider
        }
        email = module.agentless_scan.controller_service_account
      }
    })
  }
  depends_on = [module.agentless_scan]
}