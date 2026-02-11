# Optional project API enablement for this feature.
# If the APIs are already enabled in the project, set install_gcp_api = false.

locals {
  pub_sub_required_services = toset([
    "pubsub.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ])
}

resource "google_project_service" "pub_sub_apis" {
  for_each = var.install_gcp_api ? local.pub_sub_required_services : toset([])

  project = var.project_id
  service = each.value

  disable_on_destroy = var.disable_api_on_destroy
}
