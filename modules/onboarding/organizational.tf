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
resource "sysdig_secure_organization" "azure_organization" {
  count = var.is_organizational ? 1 : 0

  management_account_id   = sysdig_secure_cloud_auth_account.google_account.id
  organizational_unit_ids = var.management_group_ids
  depends_on              = [google_organization_iam_member.browser]
}