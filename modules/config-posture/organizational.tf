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

#---------------------------------------------------------------------------------------------
# role permissions for CSPM (GCP Predefined Roles for Sysdig Cloud Secure Posture Management)
#---------------------------------------------------------------------------------------------
resource "google_organization_iam_member" "cspm" {
  # adding ciem role with permissions to the service account alongside cspm roles
  for_each = var.is_organizational ? toset(["roles/cloudasset.viewer", "roles/iam.workloadIdentityUser", "roles/logging.viewer", "roles/cloudfunctions.viewer", "roles/cloudbuild.builds.viewer", "roles/orgpolicy.policyViewer", "roles/recommender.viewer", "roles/iam.serviceAccountViewer", "roles/iam.organizationRoleViewer", "roles/container.clusterViewer", "roles/compute.viewer"]) : []

  org_id = data.google_organization.org[0].org_id
  role   = each.key
  member = "serviceAccount:${google_service_account.posture_auth.email}"
}