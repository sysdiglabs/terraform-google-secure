#---------------------------------------------------------------------------------------------
# Ensure installation flow for foundational onboarding has been completed before
# installing additional Sysdig features.
#---------------------------------------------------------------------------------------------

module "agentless-scan" {
  source                   = "../../../modules/agentless-scan"
  project_id               = module.onboarding.project_id
  is_organizational        = module.onboarding.is_organizational
  organization_domain      = module.onboarding.organization_domain
  sysdig_secure_account_id = module.onboarding.sysdig_secure_account_id
}

resource "sysdig_secure_cloud_auth_account_feature" "agentless_scanning" {
  account_id = module.onboarding.sysdig_secure_account_id
  type       = "FEATURE_SECURE_AGENTLESS_SCANNING"
  enabled    = true
  components = [module.agentless-scan.agentless_scan_component_id]
  depends_on = [module.agentless-scan]
}
