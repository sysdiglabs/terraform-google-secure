###################################################
# Create Service Account and setup permissions
###################################################

resource "google_service_account" "sa" {
  project      = var.project_id
  account_id   = var.service_account_name
  display_name = "Service account for secure posture management"
}

#---------------------------------
# role permissions for onboarding
#---------------------------------
resource "google_project_iam_member" "browser" {
  count = var.is_organizational ? 0 : 1

  project = var.project_id
  role    = "roles/browser"
  member  = "serviceAccount:${google_service_account.sa.email}"
}

#---------------------------------------------------------------------------------------------
# role permissions for CSPM (GCP Predefined Roles for Sysdig Cloud Secure Posture Management)
#---------------------------------------------------------------------------------------------
resource "google_project_iam_member" "cloudasset_viewer" {
  for_each = var.is_organizational ? [] : toset(["roles/cloudasset.viewer", "roles/iam.serviceAccountTokenCreator", , "roles/logging.viewer"])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.sa.email}"
}

#---------------------------------------------------------------------------------------
# role permissions for CIEM (GCP Predefined Roles for Sysdig Cloud Identity Management)
#---------------------------------------------------------------------------------------
resource "google_project_iam_member" "identity_mgmt" {
  for_each = var.is_organizational ? [] : toset(["roles/recommender.viewer", "roles/iam.serviceAccountViewer", "roles/iam.roleViewer", "roles/container.clusterViewer", "roles/compute.viewer"])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.sa.email}"
}

#--------------------------------
# service account private key
#--------------------------------
resource "google_service_account_key" "secure_service_account_key" {
  service_account_id = google_service_account.sa.name
}