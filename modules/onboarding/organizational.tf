#--------------#
# Organization #
#--------------#

data "google_organization" "org" {
  count  = var.is_organizational ? 1 : 0
  domain = var.organization_domain
}

###################################################
# Setup Service Account permissions
###################################################

#---------------------------------
# role permissions for onboarding
#---------------------------------
resource "google_organization_iam_member" "browser" {
  count = var.is_organizational ? 1 : 0

  org_id = data.google_organization.org[0].org_id
  role   = "roles/browser"
  member = "serviceAccount:${google_service_account.onboarding_auth.email}"
}

#---------------------------------------------------------------------------------------------
# Call Sysdig Backend to create organization with foundational onboarding
# (ensure it is called after all above cloud resources are created)
#---------------------------------------------------------------------------------------------
resource "sysdig_secure_organization" "google_organization" {
  count = var.is_organizational ? 1 : 0

  management_account_id          = sysdig_secure_cloud_auth_account.google_account.id
  organizational_unit_ids        = local.check_old_management_group_ids_param ? var.management_group_ids : []
  organization_root_id           = local.root_org[0]
  included_organizational_groups = local.check_old_management_group_ids_param ? [] : local.prefixed_include_folders
  excluded_organizational_groups = local.check_old_management_group_ids_param ? [] : local.prefixed_exclude_folders
  included_cloud_accounts        = local.check_old_management_group_ids_param ? [] : var.include_projects
  excluded_cloud_accounts        = local.check_old_management_group_ids_param ? [] : var.exclude_projects
  automatic_onboarding           = var.enable_automatic_onboarding
  depends_on = [
    google_organization_iam_member.browser,
    sysdig_secure_cloud_auth_account.google_account,
    sysdig_secure_cloud_auth_account_component.onboarding_service_principal,
  ]
  lifecycle {
    ignore_changes = [automatic_onboarding]
  }
}