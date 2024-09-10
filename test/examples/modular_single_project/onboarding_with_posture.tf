provider "google" {
  project = "org-child-project-1"
  region  = "us-west1"
}

terraform {
  required_providers {
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = "~> 1.34.0"
    }
  }
}

provider "sysdig" {
  sysdig_secure_url       = "https://secure-staging.sysdig.com"
  sysdig_secure_api_token = "3aec5684-d355-4dd0-8e0e-4b87af8537f3"
}

module "onboarding" {
  source      = "../../../modules/onboarding"
  project_id  = "org-child-project-1"
}

module "config-posture" {
  source                   = "../../../modules/config-posture"
  project_id               = module.onboarding.project_id
  sysdig_secure_account_id = module.onboarding.sysdig_secure_account_id
}

resource "sysdig_secure_cloud_auth_account_feature" "config_posture" {
  account_id = module.onboarding.sysdig_secure_account_id
  type       = "FEATURE_SECURE_CONFIG_POSTURE"
  enabled    = true
  components = [module.config-posture.service_principal_component_id]
  depends_on = [module.config-posture]
}