terraform {
  required_version = ">=1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.1, < 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1, < 4.0"
    }
    sysdig = {
      # TODO. restore when PR is merged https://github.com/sysdiglabs/terraform-provider-sysdig/pull/480
#      source  = "sysdiglabs/sysdig"

      # local testing with previous PR
      source = "terraform.example.com/sysdiglabs/sysdig"
      version = "~> 1.23.0"
    }
  }
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
          pool_provider_id = module.agentless-scan.workload_identity_pool_provider
        }
        email = module.agentless-scan.controller_service_account
      }
    })
  }
  depends_on = [module.agentless-scan]
}
