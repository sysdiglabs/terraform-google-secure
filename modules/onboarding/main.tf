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

// suffix to uniquely identify onboarding service account during multiple installs. If suffix value is not provided, this will generate a random value.
resource "random_id" "suffix" {
  count       = var.suffix == null ? 1 : 0
  byte_length = 3
}

locals {
  suffix = var.suffix == null ? random_id.suffix[0].hex : var.suffix
}

resource "google_service_account" "onboarding_auth" {
  # service account name cannot be longer than 30 characters
  account_id   = "sysdig-onboarding-${local.suffix}"
  display_name = "Sysdig Onboarding Auth Service Account"
  project      = var.project_id
}

#------------------------------------------------------------#
# Configure Workload Identity Federation for auth            #
# See https://cloud.google.com/iam/docs/access-resources-aws #
#------------------------------------------------------------#

resource "google_iam_workload_identity_pool" "onboarding_auth_pool" {
  project                   = var.project_id
  workload_identity_pool_id = "sysdig-secure-onboarding-${local.suffix}"
}

resource "google_iam_workload_identity_pool_provider" "onboarding_auth_pool_provider" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.onboarding_auth_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "sysdig-onboarding-${local.suffix}"
  display_name                       = "Sysdigcloud onboarding auth"
  description                        = "AWS based pool provider for Sysdig Secure Data Onboarding resources"
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
# role permissions for Onboarding (GCP Predefined Roles for Sysdig Cloud Onboarding)
#---------------------------------------------------------------------------------------------
resource "google_project_iam_member" "browser" {
  count = var.is_organizational ? 0 : 1

  project = var.project_id
  role    = "roles/browser"
  member  = "serviceAccount:${google_service_account.onboarding_auth.email}"
}

# attaching WIF as a member to the service account for auth
resource "google_service_account_iam_member" "custom_onboarding_auth" {
  service_account_id = google_service_account.onboarding_auth.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.onboarding_auth_pool.workload_identity_pool_id}/attribute.aws_role/arn:aws:sts::${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id}:assumed-role/${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_role_name}/${data.sysdig_secure_tenant_external_id.external_id.external_id}"
}

# add some timing for SA and permissions to be completely ready before calling Sysdig Backend, ensure that onboarding will pass first time
resource "time_sleep" "wait_for_apply_google_permissions" {
  depends_on = [google_organization_iam_member.browser, google_project_iam_member.browser]

  create_duration = "30s"
}

#---------------------------------------------------------------------------------------------
# Call Sysdig Backend to create account with foundational onboarding
# (ensure it is called after all above cloud resources are created using explicit depends_on)
#---------------------------------------------------------------------------------------------

resource "sysdig_secure_cloud_auth_account" "google_account" {
  enabled            = true
  provider_id        = var.project_id
  provider_type      = "PROVIDER_GCP"
  provider_alias     = data.google_project.project.name
  provider_tenant_id = var.organization_domain
  depends_on = [
    google_service_account.onboarding_auth,
    google_iam_workload_identity_pool.onboarding_auth_pool,
    google_iam_workload_identity_pool_provider.onboarding_auth_pool_provider,
    google_project_iam_member.browser,
    google_service_account_iam_member.custom_onboarding_auth,
    time_sleep.wait_for_apply_google_permissions
  ]

  lifecycle {
    ignore_changes = [
      component,
      feature
    ]
  }
}

#--------------------------------------------------------------------------------------------------------------
# Call Sysdig Backend to add the service-principal integration for Onboarding to the Sysdig Cloud Account
#--------------------------------------------------------------------------------------------------------------
resource "sysdig_secure_cloud_auth_account_component" "onboarding_service_principal" {
  account_id = sysdig_secure_cloud_auth_account.google_account.id
  type       = "COMPONENT_SERVICE_PRINCIPAL"
  instance   = "secure-onboarding"
  version    = "v0.1.0"
  service_principal_metadata = jsonencode({
    gcp = {
      workload_identity_federation = {
        pool_id          = google_iam_workload_identity_pool.onboarding_auth_pool.workload_identity_pool_id
        pool_provider_id = google_iam_workload_identity_pool_provider.onboarding_auth_pool_provider.workload_identity_pool_provider_id
        project_number   = data.google_project.project.number
      }
      email = google_service_account.onboarding_auth.email
    }
  })
  depends_on = [
    sysdig_secure_cloud_auth_account.google_account,
    google_service_account.onboarding_auth,
    google_iam_workload_identity_pool.onboarding_auth_pool,
    google_iam_workload_identity_pool_provider.onboarding_auth_pool_provider,
    google_project_iam_member.browser,
    google_service_account_iam_member.custom_onboarding_auth,
    time_sleep.wait_for_apply_google_permissions
  ]
}
