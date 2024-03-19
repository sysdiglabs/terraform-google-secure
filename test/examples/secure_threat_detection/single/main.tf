provider "google" {
  project = "mytestproject"
  region  = "us-west1"
}

module "single-project-threat-detection" {
  source        = "../../../..//modules/services/webhook-datasource"
  project_id    = "mytestproject"
  push_endpoint = "test_sysdig_secure_cloudingestion_endpoint"
  external_id   = "external_id"
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

    secure_threat_detection {
      enabled    = true
      components = ["COMPONENT_WEBHOOK_DATASOURCE/secure-runtime", "COMPONENT_SERVICE_PRINCIPAL/secure-runtime"]
    }
  }
  component {
    type     = "COMPONENT_WEBHOOK_DATASOURCE"
    instance = "secure-runtime"
    webhook_datasource_metadata = jsonencode({
      gcp = {
        webhook_datasource = {
          pubsub_topic_name      = module.single-project-threat-detection.ingestion_pubsub_topic_name
          sink_name              = module.single-project-threat-detection.ingestion_sink_name
          push_subscription_name = module.single-project-threat-detection.ingestion_push_subscription_name
          push_endpoint          = module.single-project-threat-detection.push_endpoint
        }
      }
    })
  }
  component {
    type     = "COMPONENT_SERVICE_PRINCIPAL"
    instance = "secure-runtime"
    service_principal_metadata = jsonencode({
      gcp = {
        workload_identity_federation = {
          pool_id          = module.single-project-threat-detection.workload_identity_pool_id
          pool_provider_id = module.single-project-threat-detection.workload_identity_pool_provider_id
          project_number   = module.single-project-threat-detection.workload_identity_project_number
        }
        email = module.single-project-threat-detection.service_account_email
      }
    })
  }
}

