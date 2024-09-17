#------------------------------------------------------------------#
# Fetch and compute required data for Service Account Key #
#------------------------------------------------------------------#

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

#---------------------------------
# role permissions for onboarding
#---------------------------------
resource "google_project_iam_member" "browser" {
  count = var.is_organizational ? 0 : 1

  project = var.project_id
  role    = "roles/browser"
  member  = "serviceAccount:${google_service_account.onboarding_auth.email}"
}

#--------------------------------
# service account private key

#--------------------------------
resource "google_service_account_key" "onboarding_service_account_key" {
  service_account_id = google_service_account.onboarding_auth.name
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

  component {
    type     = "COMPONENT_SERVICE_PRINCIPAL"
    instance = "secure-onboarding"
    version  = "v0.1.0"
    service_principal_metadata = jsonencode({
      gcp = {
        key = google_service_account_key.onboarding_service_account_key.private_key
      }
    })
  }

  depends_on = [
    google_service_account.onboarding_auth,
    google_project_iam_member.browser,
    google_service_account_key.onboarding_service_account_key
  ]

  lifecycle {
    ignore_changes = [
      component,
      feature
    ]
  }
}