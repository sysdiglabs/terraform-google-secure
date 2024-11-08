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
resource "google_organization_iam_member" "controller" {
  # adding ciem role with permissions to the service account alongside cspm roles
  for_each = var.is_organizational ? toset([
    "artifactregistry.repositories.downloadArtifacts",
    "artifactregistry.repositories.get",
    "artifactregistry.repositories.list",
    "artifactregistry.dockerimages.get",
    "artifactregistry.dockerimages.list",
    "storage.objects.get",
    "storage.buckets.list",
    "storage.objects.list",

    # workload identity federation
  "iam.serviceAccounts.getAccessToken"]) : []

  org_id = data.google_organization.org[0].org_id
  role   = each.key
  member = "serviceAccount:${google_service_account.controller.email}"
}