provider "sysdig" {
  sysdig_secure_url       = "https://secure-staging.sysdig.com"
  sysdig_secure_api_token = "12124235"
}

resource "sysdig_secure_cloud_auth_account" "gcp_project" {
  enabled       = true
  provider_id   = "org-child-project-1"
  provider_type = "PROVIDER_GCP"

  feature {
    secure_agentless_scanning {
      enabled    = true
      components = ["COMPONENT_SERVICE_PRINCIPAL/secure-scanning"]
    }
  }


  component {
    type     = "COMPONENT_SERVICE_PRINCIPAL"
    instance = "secure-onboarding"
    service_principal_metadata = jsonencode({
      gcp = {
        key = module.organization-posture.service_account_key
      }
    })
  }


  component {
    type     = "COMPONENT_SERVICE_PRINCIPAL"
    instance = "secure-scanning"
    service_principal_metadata = jsonencode({
      gcp = {
        workload_identity_federation = {
          pool_provider_id = module.cloud_host.workload_identity_pool_provider
        }
        email = module.cloud_host.controller_service_account
      }
    })
  }

  depends_on = [module.cloud_host, module.organization-posture]
}

resource "sysdig_secure_organization" "gcp_organization_myproject" {
  management_account_id = sysdig_secure_cloud_auth_account.gcp_project.id
  depends_on = [module.organization-posture]
}