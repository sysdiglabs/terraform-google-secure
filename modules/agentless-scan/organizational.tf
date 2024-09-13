#-----------------------------------------------------------------------------------------
# Fetch the data sources
#-----------------------------------------------------------------------------------------

data "google_organization" "org" {
  count  = var.is_organizational ? 1 : 0
  domain = var.organization_domain
}

#-----------------------------------------------------------------------------------------
# Custom IAM roles and bindings
#-----------------------------------------------------------------------------------------

resource "google_organization_iam_custom_role" "controller" {
  count = var.is_organizational ? 1 : 0

  org_id      = data.google_organization.org[0].org_id
  role_id     = "${var.role_name}Discovery${title(local.suffix)}"
  title       = "${var.role_name}, for Host Discovery"
  permissions = local.host_discovery_permissions
}

resource "google_organization_iam_binding" "controller_custom" {
  count = var.is_organizational ? 1 : 0

  org_id = data.google_organization.org[0].org_id
  role   = google_organization_iam_custom_role.controller[0].id
  members = [
    "serviceAccount:${google_service_account.controller.email}",
  ]
}

resource "google_organization_iam_custom_role" "worker_role" {
  count = var.is_organizational ? 1 : 0

  org_id      = data.google_organization.org[0].org_id
  role_id     = "${var.role_name}Scan${title(local.suffix)}"
  title       = "${var.role_name}, for Host Scan"
  permissions = local.host_scan_permissions
}

resource "google_organization_iam_binding" "admin_account_iam" {
  count = var.is_organizational ? 1 : 0

  org_id = data.google_organization.org[0].org_id
  role   = google_organization_iam_custom_role.worker_role[0].id
  members = [
    "serviceAccount:${data.sysdig_secure_agentless_scanning_assets.assets.gcp.worker_identity}",
  ]
}
