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
resource "google_organization_iam_custom_role" "custom_role" {
  count = var.is_organizational ? 1 : 0

  org_id  = data.google_organization.org[0].org_id
  role_id = "${var.role_name}vmWorkloadScanningRole${title(local.suffix)}"
  title   = "VM Workload Scanning Role"
  permissions = [
    "artifactregistry.repositories.downloadArtifacts",
    "artifactregistry.repositories.get",
    "artifactregistry.repositories.list",
    "artifactregistry.dockerimages.get",
    "artifactregistry.dockerimages.list",
    "storage.objects.get",
    "storage.buckets.list",
    "storage.objects.list",
    "iam.serviceAccounts.getAccessToken"
  ]
}

resource "google_organization_iam_member" "controller" {
  count = var.is_organizational ? 1 : 0

  org_id = data.google_organization.org[0].org_id
  role   = "organizations/${data.google_organization.org[0].org_id}/roles/${google_organization_iam_custom_role.custom_role[0].role_id}"
  member = "serviceAccount:${google_service_account.controller.email}"
}
