provider "google" {
  project = "mytestproject"
  region  = "us-west1"
}

provider "sysdig" {
  sysdig_secure_url       = "https://secure-staging.sysdig.com"
  sysdig_secure_api_token = "12124235"
}

module "agentless-scan" {
  source          = "../../../..//modules/services/agentless-scan"
  project_id      = "mytestproject"
  sysdig_account_id = "012345678"
  worker_identity = "foo@bar.com"
}
