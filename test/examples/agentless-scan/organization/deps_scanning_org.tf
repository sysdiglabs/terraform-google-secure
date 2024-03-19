# this is required for organizational setup (+cloud-host vm)

module "organization_posture" {
  source               = "sysdiglabs/secure/google//modules/services/service-principal"
  project_id           = "org-child-project-1"
  service_account_name = "sysdig-secure-igm6"
  is_organizational    = true
  organization_domain  = "draios.com"
}
