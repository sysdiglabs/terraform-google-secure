#------------------------------------------------------------------#
# Fetch and compute required data for Workload Identity Federation #
#------------------------------------------------------------------#

data "sysdig_secure_trusted_cloud_identity" "trusted_identity" {
  cloud_provider = "gcp"
}

data "google_project" "project" {
  project_id = var.project_id
}

// suffix to uniquely identify WIF pool and provider during multiple installs. If suffix value is not provided, this will generate a random value.
resource "random_id" "suffix" {
  count       = var.suffix == null ? 1 : 0
  byte_length = 3
}

locals {
  suffix = var.suffix == null ? random_id.suffix[0].hex : var.suffix
}

resource "google_service_account" "onboarding_auth" {
  account_id   = "sysdig-onboarding-${local.suffix}"
  display_name = "Sysdig Onboarding Auth Service Account"
  project      = var.project_id
}

resource "google_service_account_iam_binding" "onboarding_auth_binding" {
  service_account_id = google_service_account.push_auth.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${google_service_account.onboarding_auth.email}",
  ]
}

#------------------------------------------------------------#
# Configure Workload Identity Federation for auth            #
# See https://cloud.google.com/iam/docs/access-resources-aws #
#------------------------------------------------------------#

resource "google_iam_workload_identity_pool" "onboarding_auth_pool" {
  project                   = var.project_id
  workload_identity_pool_id = "sysdig-onboarding-${local.suffix}"
}

resource "google_iam_workload_identity_pool_provider" "onboarding_auth_pool_provider" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.onboarding_auth_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "sysdig-onboarding-${local.suffix}"
  display_name                       = "Sysdigcloud onboarding auth"
  description                        = "AWS identity pool provider for Sysdig Secure Data Onboarding resources"
  disabled                           = false

  attribute_condition = "attribute.aws_role==\"arn:aws:sts::${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id}:assumed-role/${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_role_name}/${var.external_id}\""

  attribute_mapping = {
    "google.subject"     = "assertion.arn",
    "attribute.aws_role" = "assertion.arn"
  }

  aws {
    account_id = data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id
  }
}

# creating custom role with project-level permissions to access onboarding resources
resource "google_project_iam_custom_role" "custom_onboarding_auth_role" {
  count = var.is_organizational ? 0 : 1

  project     = var.project_id
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

# adding custom role with project-level permissions to the service account for auth
resource "google_project_iam_member" "custom" {
  count = var.is_organizational ? 0 : 1

  project = var.project_id
  role    = google_project_iam_custom_role.custom_onboarding_auth_role[0].id
  member  = "serviceAccount:${google_service_account.onboarding_auth.email}"
}

# attaching WIF as a member to the service account for auth
resource "google_service_account_iam_member" "custom_auth" {
  service_account_id = google_service_account.onboarding_auth.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.onboarding_auth_pool.workload_identity_pool_id}/attribute.aws_role/arn:aws:sts::${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id}:assumed-role/${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_role_name}/${var.external_id}"
}