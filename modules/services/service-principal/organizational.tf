###################################################
# Fetch & compute required data
###################################################

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
  depends_on = [null_resource.delay]
  count      = var.is_organizational ? 1 : 0

  org_id = data.google_organization.org[0].org_id
  role   = "roles/browser"
  member = "serviceAccount:${google_service_account.sa.email}"
}

#---------------------------------------------------------------------------------------------
# role permissions for CSPM (GCP Predefined Roles for Sysdig Cloud Secure Posture Management)
#---------------------------------------------------------------------------------------------
resource "google_organization_iam_member" "cspm" {
  depends_on = [null_resource.delay]
  for_each   = var.is_organizational ? toset(["roles/cloudasset.viewer", "roles/iam.serviceAccountTokenCreator", "roles/logging.viewer"]) : []

  org_id = data.google_organization.org[0].org_id
  role   = each.key
  member = "serviceAccount:${google_service_account.sa.email}"
}

#---------------------------------------------------------------------------------------
# role permissions for CIEM (GCP Predefined Roles for Sysdig Cloud Identity Management)
#---------------------------------------------------------------------------------------
resource "google_organization_iam_member" "identity_mgmt" {
  depends_on = [null_resource.delay]
  for_each   = var.is_organizational ? toset(["roles/recommender.viewer", "roles/iam.serviceAccountViewer", "roles/iam.organizationRoleViewer", "roles/container.clusterViewer", "roles/compute.viewer"]) : []

  org_id = data.google_organization.org[0].org_id
  role   = each.key
  member = "serviceAccount:${google_service_account.sa.email}"
}