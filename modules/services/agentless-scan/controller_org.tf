resource "google_organization_iam_custom_role" "controller" {
  count = local.is_organizational ? 1 : 0

  org_id      = data.google_organization.org[0].id
  role_id     = "${var.role_name}Controller${title(local.suffix)}"
  title       = "Role for Sysdig Agentless Host Workers"
  permissions = local.host_discovery_permissions
}

resource "google_organization_iam_binding" "controller_custom" {
  count = local.is_organizational ? 1 : 0

  org_id = data.google_organization.org[0].id
  role   = google_organization_iam_custom_role.controller[0].id
  members = [
    "serviceAccount:${google_service_account.controller.email}",
  ]
}