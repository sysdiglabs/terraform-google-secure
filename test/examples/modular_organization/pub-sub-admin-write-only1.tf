#---------------------------------------------------------------------------------------------
# Ensure installation flow for foundational onboarding has been completed before
# installing additional Sysdig features.
#---------------------------------------------------------------------------------------------

module "pub-sub" {
  source                   = "../../../modules/integrations/pub-sub"
  project_id               = module.onboarding.project_id
  is_organizational        = module.onboarding.is_organizational
  organization_domain      = module.onboarding.organization_domain
  sysdig_secure_account_id = module.onboarding.sysdig_secure_account_id

  install_gcp_api        = true
  disable_api_on_destroy = false

  ingestion_sink_filter = ""
  audit_log_config = [
    {
      service    = "allServices"
      log_config = []
    }
  ]
  exclude_logs_filter = []
}

resource "sysdig_secure_cloud_auth_account_feature" "threat_detection" {
  account_id = module.onboarding.sysdig_secure_account_id
  type       = "FEATURE_SECURE_THREAT_DETECTION"
  enabled    = true
  components = [module.pub-sub.pubsub_datasource_component_id]
  depends_on = [module.pub-sub]
}

resource "sysdig_secure_cloud_auth_account_feature" "identity_entitlement_advanced" {
  account_id = module.onboarding.sysdig_secure_account_id
  type       = "FEATURE_SECURE_IDENTITY_ENTITLEMENT"
  enabled    = true
  components = concat(tolist(sysdig_secure_cloud_auth_account_feature.identity_entitlement_basic.components), [module.pub-sub.pubsub_datasource_component_id])
  depends_on = [module.pub-sub, sysdig_secure_cloud_auth_account_feature.identity_entitlement_basic, module.pub-sub.post_ciem_basic_delay]
  flags      = { "CIEM_FEATURE_MODE" : "advanced" }

  lifecycle {
    ignore_changes = [flags, components]
  }
}
