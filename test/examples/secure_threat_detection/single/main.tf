provider "google" {
  project = "mytestproject"
  region  = "us-west1"
}

module "single-project-threat-detection" {
  source        = "../../../..//modules/services/webhook-datasource"
  project_id    = "mytestproject"
  push_endpoint = "test_sysdig_secure_cloudingestion_endpoint"
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
      components = ["COMPONENT_WEBHOOK_DATASOURCE/secure-runtime"]
    }
  }
  component {
    type     = "COMPONENT_WEBHOOK_DATASOURCE"
    instance = "secure-runtime"
  }
}

