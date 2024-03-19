resource "google_project_iam_custom_role" "controller" {
  count = local.is_organizational ? 0 : 1

  project     = var.project_id
  role_id     = "${var.role_name}Discovery${title(local.suffix)}"
  title       = "${var.role_name}, for Host Discovery"
  permissions = local.host_discovery_permissions
}

resource "google_project_iam_binding" "controller_custom" {
  count = local.is_organizational ? 0 : 1

  project = var.project_id
  role    = google_project_iam_custom_role.controller[0].id
  members = [
    "serviceAccount:${google_service_account.controller.email}",
  ]
}
