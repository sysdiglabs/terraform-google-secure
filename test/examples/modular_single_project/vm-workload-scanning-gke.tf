module "vm_workload_scanning" {
  source            	  = "../../../modules/vm-workload-scanning"

  project_id               = module.onboarding.project_id
  sysdig_secure_account_id = module.onboarding.sysdig_secure_account_id
}


resource "sysdig_secure_cloud_auth_account_feature" "config_gke" {
  account_id = module.onboarding.sysdig_secure_account_id
  type       = "FEATURE_SECURE_WORKLOAD_SCANNING_KUBERNETES"
  enabled    = true
  components = [module.vm_workload_scanning.vm_workload_scanning_component_id]
  depends_on = [module.vm_workload_scanning]
}