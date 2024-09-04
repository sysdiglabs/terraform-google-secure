#--------------#
# Organization #
#--------------#

data "google_organization" "org" {
  count  = var.is_organizational ? 1 : 0
  domain = var.organization_domain
}

# creating custom role with organization-level permissions to access onboarding resources
resource "google_organization_iam_custom_role" "custom_onboarding_auth_role" {
  count = var.is_organizational ? 1 : 0

  org_id      = data.google_organization.org[0].org_id
  role_id     = var.role_name
  title       = "Sysdigcloud Onboarding Auth Role"
  description = "A Role providing the required permissions for Sysdig Backend to read cloud resources created for onboarding"
  permissions = [
    "pubsub.topics.get",
    "pubsub.topics.list",
    "pubsub.subscriptions.get",
    "pubsub.subscriptions.list",
    "logging.sinks.get",
    "logging.sinks.list",
  ]
}

# adding custom role with organization-level permissions to the service account for auth
resource "google_organization_iam_member" "custom" {
  count = var.is_organizational ? 1 : 0

  org_id = data.google_organization.org[0].org_id
  role   = google_organization_iam_custom_role.custom_onboarding_auth_role[0].id
  member = "serviceAccount:${google_service_account.onboarding_auth.email}"
}