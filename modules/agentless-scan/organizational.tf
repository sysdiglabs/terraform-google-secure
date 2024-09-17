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

resource "google_organization_iam_custom_role" "controller_role" {
  count = var.is_organizational ? 1 : 0

  org_id      = data.google_organization.org[0].org_id
  role_id     = "SysdigCloudVMDiscovery${local.suffix}"
  title       = "SysdigCloudVM, for Host Discovery"
  permissions = local.host_discovery_permissions
}

resource "google_organization_iam_binding" "controller_custom" {
  count = var.is_organizational ? 1 : 0

  org_id = data.google_organization.org[0].org_id
  role   = google_organization_iam_custom_role.controller_role[0].id
  members = [
    "serviceAccount:${google_service_account.controller.email}",
  ]
}

resource "google_organization_iam_custom_role" "worker_role" {
  count = var.is_organizational ? 1 : 0

  org_id      = data.google_organization.org[0].org_id
  role_id     = "SysdigCloudVMScan${local.suffix}"
  title       = "SysdigCloudVM, for Host Scan"
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
