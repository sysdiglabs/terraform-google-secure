provider "google" {
  project = "mytestproject"
  region  = "us-west1"
}

module "agentless-scan" {
  source          = "../../../..//modules/services/agentless-scan"
  project_id      = "mytestproject"
  worker_identity = "foo@bar.com"
}
