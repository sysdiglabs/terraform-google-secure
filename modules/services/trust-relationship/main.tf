###################################################
# Create Service Account and setup permissions
###################################################

resource "google_service_account" "sa" {
  project = var.project_id

  account_id   = var.service_account_name
  display_name = "Service account for trust-relationship"
}

#---------------------------------
# role permissions for onboarding
#---------------------------------
resource "google_project_iam_member" "browser" {
  count   = var.is_organizational ? 0 : 1
  project = var.project_id

  role   = "roles/browser"
  member = "serviceAccount:${google_service_account.sa.email}"
}

#----------------------------
# role permissions for CSPM
#----------------------------
resource "google_project_iam_member" "cloudasset_viewer" {
  count   = var.is_organizational ? 0 : 1
  project = var.project_id

  role   = "roles/cloudasset.viewer"
  member = "serviceAccount:${google_service_account.sa.email}"
}

#----------------------------
# role permissions for CIEM
#----------------------------
resource "google_project_iam_member" "recommender_viewer" {
  count   = var.is_organizational ? 0 : 1
  project = var.project_id

  role   = "roles/recommender.viewer"
  member = "serviceAccount:${google_service_account.sa.email}"
}

# custom role for CIEM
resource "google_project_iam_custom_role" "custom" {
  count   = var.is_organizational ? 0 : 1
  project = var.project_id

  role_id     = "admin.directory.group.readonly"
  title       = "Sysdig Cloud Trust Relationship Role"
  description = "A Role providing the required permissions for Sysdig Cloud that are not included in predefined roles."
  permissions = [
    "iam.serviceAccountKeys.get",
    "iam.serviceAccountKeys.list",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.list",
    "iam.roles.get",
    "iam.roles.list",
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy"
  ]
}

resource "google_project_iam_member" "custom" {
  count   = var.is_organizational ? 0 : 1
  project = var.project_id

  role   = google_project_iam_custom_role.custom[0].id
  member = "serviceAccount:${google_service_account.sa.email}"
}

#-----------------------------
# service account private key
#-----------------------------
resource "google_service_account_key" "secure_service_account_key" {
  service_account_id = google_service_account.sa.name
}