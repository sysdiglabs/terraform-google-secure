###################################################
# Create Service Account and setup permissions
###################################################

resource "google_service_account" "sa" {
  project      = var.project_id
  account_id   = var.service_account_name
  display_name = "Service account for secure posture management"
}

#---------------------------------------------------------------------------------------------
# role permissions for onboarding
# role permissions for CSPM (GCP Predefined Roles for Sysdig Cloud Secure Posture Management)
# role permissions for CIEM (GCP Predefined Roles for Sysdig Cloud Identity Management)
#---------------------------------------------------------------------------------------------
resource "google_project_iam_member" "onboarding_posture_identity-mgmt" {
  for_each = var.is_organizational ? [] : toset([
    "roles/browser",
    "roles/cloudasset.viewer", "roles/iam.serviceAccountTokenCreator",
    "roles/recommender.viewer", "roles/iam.serviceAccountViewer", "roles/iam.roleViewer", "roles/container.clusterViewer", "roles/compute.viewer"
  ])

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