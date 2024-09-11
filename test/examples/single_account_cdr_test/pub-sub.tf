#---------------------------------------------------------------------------------------------
# Ensure installation flow for foundational onboarding has been completed before
# installing additional Sysdig features.
#---------------------------------------------------------------------------------------------

module "webhook-datasource" {
  source        = "../../../modules/integrations/pub-sub"
  project_id    = module.onboarding.project_id
  sysdig_secure_account_id = module.onboarding.sysdig_secure_account_id
}

resource "sysdig_secure_cloud_auth_account_feature" "threat_detection" {
  account_id = module.onboarding.sysdig_secure_account_id
  type       = "FEATURE_SECURE_THREAT_DETECTION"
  enabled    = true
  components = [ module.webhook-datasource.webhook_datasource_component_id ]
  depends_on = [ module.webhook-datasource ]
}

resource "sysdig_secure_cloud_auth_account_feature" "identity_entitlement" {
  account_id = module.onboarding.sysdig_secure_account_id
  type       = "FEATURE_SECURE_IDENTITY_ENTITLEMENT"
  enabled    = true
  components = [module.webhook-datasource.webhook_datasource_component_id]
  depends_on = [sysdig_secure_cloud_auth_account_feature.config_posture, sysdig_secure_cloud_auth_account_feature.threat_detection]
}