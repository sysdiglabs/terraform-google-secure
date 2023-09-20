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
resource "google_organization_iam_member" "onboarding_role" {
  count = var.is_organizational ? 1 : 0

  org_id = data.google_organization.org[0].org_id
  role   = "roles/browser"
  member = "serviceAccount:${google_service_account.sa.email}"
}

#--------------------------------------------------------------------------------------
# role permissions for CSPM (GCP Predefined Roles for Sysdig Cloud Trust Relationship)
#--------------------------------------------------------------------------------------
resource "google_organization_iam_member" "trust_relationship_role" {
  for_each = var.is_organizational ? toset(["roles/cloudasset.viewer"]) : []

  org_id = data.google_organization.org[0].org_id
  role   = each.key
  member = "serviceAccount:${google_service_account.sa.email}"
}

#---------------------------------------------------------------------------------------
# role permissions for CIEM (GCP Predefined Roles for Sysdig Cloud Identity Management)
#---------------------------------------------------------------------------------------
resource "google_organization_iam_member" "identity_mgmt_role" {
  for_each = var.is_organizational ? toset(["roles/recommender.viewer", "roles/iam.serviceAccountViewer", "roles/iam.organizationRoleViewer"]) : []

  org_id = data.google_organization.org[0].org_id
  role   = each.key
  member = "serviceAccount:${google_service_account.sa.email}"
}