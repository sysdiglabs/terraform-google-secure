#------------------------------------------------------------------#
# Fetch and compute required data for Workload Identity Federation #
#------------------------------------------------------------------#

data "sysdig_secure_trusted_cloud_identity" "trusted_identity" {
  cloud_provider = "gcp"
}

data "sysdig_secure_tenant_external_id" "external_id" {}

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

resource "google_service_account" "posture_auth" {
  # service account name cannot be longer than 30 characters
  account_id   = "sysdig-posture-${local.suffix}"
  display_name = "Sysdig Config Posture Auth Service Account"
  project      = var.project_id
}

resource "google_service_account_iam_binding" "posture_auth_binding" {
  service_account_id = google_service_account.posture_auth.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${google_service_account.posture_auth.email}",
  ]
}

#------------------------------------------------------------#
# Configure Workload Identity Federation for auth            #
# See https://cloud.google.com/iam/docs/access-resources-aws #
#------------------------------------------------------------#

resource "google_iam_workload_identity_pool" "posture_auth_pool" {
  project                   = var.project_id
  workload_identity_pool_id = "sysdig-secure-posture-${local.suffix}"
}

resource "google_iam_workload_identity_pool_provider" "posture_auth_pool_provider" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.posture_auth_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "sysdig-posture-${local.suffix}"
  display_name                       = "Sysdigcloud config posture auth"
  description                        = "AWS identity pool provider for Sysdig Secure Data Config Posture resources"
  disabled                           = false

  attribute_condition = "attribute.aws_role==\"arn:aws:sts::${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id}:assumed-role/${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_role_name}/${data.sysdig_secure_tenant_external_id.external_id.external_id}\""

  attribute_mapping = {
    "google.subject"     = "assertion.arn",
    "attribute.aws_role" = "assertion.arn"
  }

  aws {
    account_id = data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id
  }
}

#---------------------------------------------------------------------------------------------
# role permissions for CSPM (GCP Predefined Roles for Sysdig Cloud Secure Posture Management)
#---------------------------------------------------------------------------------------------
resource "google_project_iam_member" "cspm" {
  for_each = var.is_organizational ? [] : toset(["roles/cloudasset.viewer", "roles/iam.workloadIdentityUser", "roles/logging.viewer", "roles/cloudfunctions.viewer", "roles/cloudbuild.builds.viewer", "roles/orgpolicy.policyViewer"])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.posture_auth.email}"
}

# attaching WIF as a member to the service account for auth
resource "google_service_account_iam_member" "custom_posture_auth" {
  service_account_id = google_service_account.posture_auth.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.posture_auth_pool.workload_identity_pool_id}/attribute.aws_role/arn:aws:sts::${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id}:assumed-role/${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_role_name}/${data.sysdig_secure_tenant_external_id.external_id.external_id}"
}

#--------------------------------------------------------------------------------------------------------------
# Call Sysdig Backend to add the service-principal integration for Config Posture to the Sysdig Cloud Account
#--------------------------------------------------------------------------------------------------------------
resource "sysdig_secure_cloud_auth_account_component" "google_service_principal" {
  account_id = var.sysdig_secure_account_id
  type       = "COMPONENT_SERVICE_PRINCIPAL"
  instance   = "secure-posture"
  version    = "v0.1.0"
  service_principal_metadata = jsonencode({
    gcp = {
      workload_identity_federation = {
        pool_id          = google_iam_workload_identity_pool.posture_auth_pool.workload_identity_pool_id
        pool_provider_id = google_iam_workload_identity_pool_provider.posture_auth_pool_provider.workload_identity_pool_provider_id
        project_number   = data.google_project.project.number
      }
      email = google_service_account.posture_auth.email
    }
  })
  depends_on = [
    google_service_account.posture_auth,
    google_service_account_iam_binding.posture_auth_binding,
    google_iam_workload_identity_pool.posture_auth_pool,
    google_iam_workload_identity_pool_provider.posture_auth_pool_provider,
    google_project_iam_member.cspm,
    google_service_account_iam_member.custom_posture_auth
  ]
}
