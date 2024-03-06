data "google_project" "project" {
  project_id = var.project_id
}

data "google_organization" "org" {
  count  = local.is_organizational ? 1 : 0
  domain = var.organization_domain
}