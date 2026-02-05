# Optional project API enablement for this feature.
# If the APIs are already enabled in the project, set install_gcp_api = false.

locals {
  onboarding_required_services = toset([
    "cloudasset.googleapis.com",
    "admin.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
  ])
}

resource "google_project_service" "onboarding_apis" {
  for_each = var.install_gcp_api ? local.onboarding_required_services : toset([])

  project = var.project_id
  service = each.value

  disable_on_destroy = var.disable_api_on_destroy
}
