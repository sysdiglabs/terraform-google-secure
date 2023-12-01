resource "google_project_iam_custom_role" "worker_role" {
  project = var.project_id
  role_id = "${var.role_name}Worker${title(local.suffix)}"
  title   = "${var.role_name} - Sysdig Agentless"
  permissions = [
    # general stuff
    "compute.zoneOperations.get",
    # disks
    "compute.disks.get",
    "compute.disks.useReadOnly",
  ]
}

resource "google_project_iam_binding" "admin-account-iam" {
  project = var.project_id
  role    = google_project_iam_custom_role.worker_role.id

  members = [
    "serviceAccount:${var.worker_identity}",
  ]
}