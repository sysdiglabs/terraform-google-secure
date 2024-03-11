provider "google" {
  project = "mytestproject"
  region  = "us-west1"
}

module "organization-threat-detection" {
  source            	= "../../../..//modules/services/webhook-datasource"
  project_id        	= "mytestproject"
  push_endpoint     	= "test_sysdig_secure_cloudingestion_endpoint"
  is_organizational 	= true
  organization_domain = "mytestorg.com"
  external_id         = "external_id"
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
      version = "~> 1.19.0"
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
          pubsub_topic_name      = module.organization-threat-detection.ingestion_pubsub_topic_name
          sink_name              = module.organization-threat-detection.ingestion_sink_name
          push_subscription_name = module.organization-threat-detection.ingestion_push_subscription_name
          push_endpoint          = module.organization-threat-detection.push_endpoint
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
          pool_id          = module.organization-threat-detection.workload_identity_pool_id
          pool_provider_id = module.organization-threat-detection.workload_identity_pool_provider_id
          project_number   = module.organization-threat-detection.workload_identity_project_number
        }
        email = module.organization-threat-detection.service_account_email
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
}

resource "sysdig_secure_organization" "gcp_organization_mytestproject" {
  management_account_id = sysdig_secure_cloud_auth_account.gcp_project_mytestproject.id
  depends_on            = [module.organization-posture]
}

