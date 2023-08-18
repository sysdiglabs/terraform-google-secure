###################################################
# Fetch & compute required data
###################################################

data "google_organization" "org" {
  count = var.is_organizational ? 1 : 0
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
  member = "serviceAccount:${google_service_account.sa.email}"
}

#----------------------------
# role permissions for CSPM
#----------------------------
resource "google_organization_iam_member" "cloudasset_viewer" {
  count = var.is_organizational ? 1 : 0
  org_id = data.google_organization.org[0].org_id

  role   = "roles/cloudasset.viewer"
  member = "serviceAccount:${google_service_account.sa.email}"
}

#----------------------------
# role permissions for CIEM
#----------------------------
resource "google_organization_iam_member" "recommender_viewer" {
  count = var.is_organizational ? 1 : 0
  org_id = data.google_organization.org[0].org_id

  role   = "roles/recommender.viewer"
  member = "serviceAccount:${google_service_account.sa.email}"
}

# custom role for CIEM
resource "google_organization_iam_custom_role" "custom" {
  count = var.is_organizational ? 1 : 0
  org_id = data.google_organization.org[0].org_id

  role_id     = "admin.directory.group.readonly"
  title       = "Sysdig Cloud Trust Relationship Role"
  description = "A Role providing the required permissions for Sysdig Cloud that are not included in predefined roles."
  permissions = [
    "iam.serviceAccountKeys.get",
    "iam.serviceAccountKeys.list",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.list",
    "resourcemanager.projects.get",
    "resourcemanager.projects.list",
    "iam.roles.get",
    "iam.roles.list",
    "resourcemanager.organizations.get",
    "resourcemanager.organizations.getIamPolicy",
    "resourcemanager.projects.getIamPolicy"
  ]
}

resource "google_organization_iam_member" "custom" {
  count = var.is_organizational ? 1 : 0
  org_id = data.google_organization.org[0].org_id

  role   = google_organization_iam_custom_role.custom[0].id
  member = "serviceAccount:${google_service_account.sa.email}"
}