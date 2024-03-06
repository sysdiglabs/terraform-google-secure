resource "google_project_iam_custom_role" "worker_role" {
  count = local.is_organizational ? 0 : 1

  project     = var.project_id
  role_id     = "${var.role_name}Worker${title(local.suffix)}"
  title       = "${var.role_name} - Sysdig Agentless"
  permissions = local.host_scan_permissions
}

resource "google_project_iam_binding" "admin_account_iam" {
  count = local.is_organizational ? 0 : 1

  project = var.project_id
  role    = google_project_iam_custom_role.worker_role[0].id
  members = [
    "serviceAccount:${var.worker_identity}",
  ]
}
