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

  ingestion_sink_filter = "protoPayload.@type = \"type.googleapis.com/google.cloud.audit.AuditLog\" (protoPayload.methodName!~ \"\\.(get|list)$\" OR protoPayload.serviceName != (\"k8s.io\" and \"storage.googleapis.com\"))"
  audit_log_config = [
    {
      service = "cloudsql.googleapis.com"
      log_config = [{ log_type = "DATA_READ",
        exempted_members = [
          "serviceAccount:my-sa@my-project.iam.gserviceaccount.com",
        ]
        },
        { log_type = "DATA_WRITE" }
      ]
    },
    {
      service = "storage.googleapis.com"
      log_config = [{ log_type = "DATA_WRITE"
      }]
    },
    {
      service    = "container.googleapis.com"
      log_config = [{ log_type = "DATA_READ" }]
    }
  ]
  exclude_logs_filter = [
    {
      name        = "nsexcllusion2"
      description = "Exclude logs from namespace-2 in k8s"
      filter      = "resource.type = k8s_container resource.labels.namespace_name=\"namespace-2\" "
    },
    {
      name        = "nsexcllusion1"
      description = "Exclude logs from namespace-1 in k8s"
      filter      = "resource.type = k8s_container resource.labels.namespace_name=\"namespace-1\" "
    }
  ]
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
  components = concat(sysdig_secure_cloud_auth_account_feature.identity_entitlement_basic.components, [module.pub-sub.pubsub_datasource_component_id])
  depends_on = [module.pub-sub, sysdig_secure_cloud_auth_account_feature.identity_entitlement_basic, module.pub-sub.post_ciem_basic_delay]
  flags      = { "CIEM_FEATURE_MODE" : "advanced" }

  lifecycle {
    ignore_changes = [flags, components]
  }
}
