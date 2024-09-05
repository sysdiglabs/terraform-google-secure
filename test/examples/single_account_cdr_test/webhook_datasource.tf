#---------------------------------------------------------------------------------------------
# Ensure installation flow for foundational onboarding has been completed before
# installing additional Sysdig features.
#---------------------------------------------------------------------------------------------

# UNCOMMENT TO TEST: FROM HERE: THIS WILL BE PART OF THE ONBOARD MODULE
# terraform {
#   required_providers {
#     sysdig = {
#       source  = "sysdiglabs/sysdig"
#       version = "~> 1.34.0"
#     }
#   }
# }
#
# provider "sysdig" {
#   sysdig_secure_url       = "https://secure-staging.sysdig.com"
#   sysdig_secure_api_token = "744c9bd8-f73d-4ef3-8250-32e976a5301d"
# }
#
# provider "google" {
#   project = "org-child-project-1"
#   region  = "us-west1"
# }
# TO HERE

module "webhook-datasource" {
  source        = "../../../modules/integrations/webhook-datasource"
  project_id    = "org-child-project-1"
  # push_endpoint and external_id are no longer needed
  # push_endpoint = "https://app-staging.sysdigcloud.com/api/cloudingestion/gcp/v2/1f6d4677-84ec-4356-bd73-c79c8a96f96a"
  # external_id = "87e82bdu28323"
  # This will come from the onboarding module: module.onboarding.sysdig_secure_account_id
  sysdig_secure_account_id = module.onboarding.sysdig_secure_account_id
}

# COMMENT TO TEST: THIS WILL BE PART OF THE SNIPPET
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
# TO HERE

# UNCOMMENT TO TEST: THIS IS NOT GOING TO BE LONGER NEEDED, SINCE WILL BE PART OF FOUNDATIONAL
# resource "sysdig_secure_cloud_auth_account" "gcp_project_org-child-project-1" {
#   enabled       = true
#   provider_id   = "org-child-project-1"
#   provider_type = "PROVIDER_GCP"
#
#   feature {
#
#     secure_threat_detection {
#       enabled    = true
#       components = ["COMPONENT_WEBHOOK_DATASOURCE/secure-runtime"]
#     }
#   }
#   component {
#     type     = "COMPONENT_WEBHOOK_DATASOURCE"
#     instance = "secure-runtime"
#     webhook_datasource_metadata = jsonencode({
#       gcp = {
#         webhook_datasource = {
#           pubsub_topic_name      = module.webhook-datasource.ingestion_pubsub_topic_name
#           sink_name              = module.webhook-datasource.ingestion_sink_name
#           push_subscription_name = module.webhook-datasource.ingestion_push_subscription_name
#           push_endpoint          = module.webhook-datasource.push_endpoint
#           routing_key            = "1f6d4677-84ec-4356-bd73-c79c8a96f96a"
#         }
#         service_principal = {
#           workload_identity_federation = {
#             pool_id          = module.webhook-datasource.workload_identity_pool_id
#             pool_provider_id = module.webhook-datasource.workload_identity_pool_provider_id
#             project_number   = module.webhook-datasource.workload_identity_project_number
#           }
#           email = module.webhook-datasource.service_account_email
#         }
#       }
#     })
#   }
#   depends_on = [module.webhook-datasource]
# }
# TO HERE