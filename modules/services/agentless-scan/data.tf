data "google_project" "project" {
  project_id = var.project_id
}

data "google_organization" "org" {
  count  = local.is_organizational ? 1 : 0
  domain = var.organization_domain
}

data "google_projects" "all_projects" {
  count  = local.is_organizational ? 1 : 0
  filter = "parent.id:${data.google_organization.org[0].org_id} lifecycleState:ACTIVE"
}
