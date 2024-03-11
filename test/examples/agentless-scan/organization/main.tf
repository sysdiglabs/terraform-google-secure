provider "google"{
  project="mytestproject"
}


module "agentless_scan" {
  source            = "../../../..//modules/services/agentless-scan"
  project_id        = "mytestproject"
  sysdig_account_id = "012345678"
  worker_identity   = "foo@bar.com"

  is_organizational = true
  organization_domain = "myorg.com"
}