provider "google" {
  project = "mytestproject"
  region  = "us-west1"
}

module "organization-posture" {
  source               = "../../../..//modules/services/service-principal"
  project_id           = "mytestproject"
  service_account_name = "sysdig-secure"
  is_organizational    = true
  organization_domain  = "mytestorg.com"
}

terraform {

  required_providers {
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = ">= 1.23.1"
    }
  }
}

provider "sysdig" {
  sysdig_secure_url       = "test_sysdig_secure_endpoint"
  sysdig_secure_api_token = "test_sysdig_secure_api_token"
}

resource "sysdig_secure_cloud_auth_account" "gcp_project_mytestproject" {
  enabled       = true
  provider_id   = "mytestproject"
  provider_type = "PROVIDER_GCP"

  feature {

    secure_identity_entitlement {
      enabled    = true
      components = ["COMPONENT_SERVICE_PRINCIPAL/secure-posture"]
    }

    secure_config_posture {
      enabled    = true
      components = ["COMPONENT_SERVICE_PRINCIPAL/secure-posture"]
    }
  }
  component {
    type     = "COMPONENT_SERVICE_PRINCIPAL"
    instance = "secure-posture"
    service_principal_metadata = jsonencode({
      gcp = {
        key = module.organization-posture.service_account_key
      }
    })
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
  depends_on = [module.organization-posture]
}

resource "sysdig_secure_organization" "gcp_organization_mytestproject" {
  management_account_id = sysdig_secure_cloud_auth_account.gcp_project_mytestproject.id
  depends_on            = [module.organization-posture]
}
