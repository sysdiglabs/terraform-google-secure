###################################################
# Create Service Account and setup permissions
###################################################

resource "google_service_account" "sa" {
  project      = var.project_id
  account_id   = var.service_account_name
  display_name = "Service account for trust-relationship"
}

#---------------------------------
# role permissions for onboarding
#---------------------------------
resource "google_project_iam_member" "onboarding_role" {
  count = var.is_organizational ? 0 : 1

  project = var.project_id
  role    = "roles/browser"
  member  = "serviceAccount:${google_service_account.sa.email}"
}

#--------------------------------------------------------------------------------------
# role permissions for CSPM (GCP Predefined Roles for Sysdig Cloud Trust Relationship)
#--------------------------------------------------------------------------------------
resource "google_project_iam_member" "trust_relationship_role" {
  for_each = var.is_organizational ? [] : toset(["roles/cloudasset.viewer", "roles/recommender.iamViewer"])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.sa.email}"
}

#---------------------------------------------------------------------------------------
# role permissions for CIEM (GCP Predefined Roles for Sysdig Cloud Identity Management)
#---------------------------------------------------------------------------------------
resource "google_project_iam_member" "identity_mgmt_role" {
  for_each = var.is_organizational ? [] : toset(["roles/recommender.viewer", "roles/iam.serviceAccountViewer", "roles/iam.roleViewer"])

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