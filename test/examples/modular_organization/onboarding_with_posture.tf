terraform {
  required_providers {
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = "~> 1.34"
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
}

module "onboarding" {
  source              = "../../../modules/onboarding"
  project_id          = "org-child-project-3"
  is_organizational   = true
  organization_domain = "draios.com"

  # legacy include/exclude org install params
  # management_group_ids = ["folders/123456789012"]

  # include/exclude parameters
  include_folders = ["123456789012", "12345678911"]
  exclude_folders = []
  include_projects = ["<project-id-1>", "<project-id-2>"]
  exclude_projects = ["<project-id-3>", "<project-id-4>"]

  # optionally pass automatic onboarding for orgs (defaults to false)
  enable_automatic_onboarding = false
}

module "config-posture" {
  source                   = "../../../modules/config-posture"
  project_id               = module.onboarding.project_id
  is_organizational        = module.onboarding.is_organizational
  organization_domain      = module.onboarding.organization_domain
  sysdig_secure_account_id = module.onboarding.sysdig_secure_account_id
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
