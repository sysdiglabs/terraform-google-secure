resource "google_organization_iam_custom_role" "worker_role" {
  count = local.is_organizational ? 1 : 0

  org_id      = data.google_organization.org[0].org_id
  role_id     = "${var.role_name}Scan${title(local.suffix)}"
  title       = "${var.role_name}, for Host Scan"
  permissions = local.host_scan_permissions
}

resource "google_organization_iam_binding" "admin_account_iam" {
  count = local.is_organizational ? 1 : 0

  org_id = data.google_organization.org[0].org_id
  role   = google_organization_iam_custom_role.worker_role[0].id
  members = [
    "serviceAccount:${var.worker_identity}",
  ]
}
