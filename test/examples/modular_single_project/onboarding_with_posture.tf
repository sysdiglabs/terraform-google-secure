terraform {
  required_providers {
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = "~> 3.3"
    }
  }
}

provider "sysdig" {
  sysdig_secure_url       = "https://secure-staging.sysdig.com"
  sysdig_secure_api_token = "API_TOKEN"
}

provider "google" {
  project = "org-child-project-3"
  region  = "us-west1"
  # For RT Inventory this is needed as a workaround due to: https://github.com/GoogleCloudPlatform/dlp-pdf-redaction/issues/25
  billing_project = "org-child-project-3"
  user_project_override = true
}

module "onboarding" {
  source     = "../../../modules/onboarding"
  project_id = "org-child-project-3"

  install_gcp_api        = true
  disable_api_on_destroy = false
}

module "config-posture" {
  source                   = "../../../modules/config-posture"
  project_id               = module.onboarding.project_id
  sysdig_secure_account_id = module.onboarding.sysdig_secure_account_id

  depends_on = [module.onboarding]
}

resource "sysdig_secure_cloud_auth_account_feature" "config_posture" {
  account_id = module.onboarding.sysdig_secure_account_id
  type       = "FEATURE_SECURE_CONFIG_POSTURE"
  enabled    = true
  components = [module.config-posture.service_principal_component_id]
  depends_on = [module.config-posture]
}

resource "sysdig_secure_cloud_auth_account_feature" "identity_entitlement_basic" {
  account_id = module.onboarding.sysdig_secure_account_id
  type       = "FEATURE_SECURE_IDENTITY_ENTITLEMENT"
  enabled    = true
  components = [module.config-posture.service_principal_component_id]
  depends_on = [module.config-posture, sysdig_secure_cloud_auth_account_feature.config_posture]
  flags = {
    "CIEM_FEATURE_MODE" : "basic"
  }

  lifecycle {
    ignore_changes = [flags, components]
  }
}
