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

#---------------------------------------------------------------------------------------------
# role permissions for onboarding
# role permissions for CSPM (GCP Predefined Roles for Sysdig Cloud Secure Posture Management)
# role permissions for CIEM (GCP Predefined Roles for Sysdig Cloud Identity Management)
#---------------------------------------------------------------------------------------------
resource "google_organization_iam_member" "onboarding_posture_identity-mgmt" {
  for_each = var.is_organizational ? toset([
    "roles/browser",
    "roles/cloudasset.viewer", "roles/iam.serviceAccountTokenCreator",
    "roles/recommender.viewer", "roles/iam.serviceAccountViewer", "roles/iam.organizationRoleViewer", "roles/container.clusterViewer", "roles/compute.viewer"]) : []

  org_id = data.google_organization.org[0].org_id
  role   = each.key
  member = "serviceAccount:${google_service_account.sa.email}"
}