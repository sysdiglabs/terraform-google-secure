provider "google" {
  project = "org-child-project-3"
  region  = "us-west1"
}

terraform {
  required_providers {
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = "~> 1.29.2"
    }
  }
}

provider "sysdig" {
  sysdig_secure_url       = "https://secure-staging.sysdig.com"
  sysdig_secure_api_token = "API_TOKEN"
}

module "onboarding" {
  source            = "../../../modules/onboarding"
  project_id        = "org-child-project-3"
  external_id       = "25ef0d887bc7a2b30089a025618e1c62"
  is_organizational = true
}