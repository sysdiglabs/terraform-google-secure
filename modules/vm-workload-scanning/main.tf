#-----------------------------------------------------------------------------------------
# Fetch the data sources
#-----------------------------------------------------------------------------------------
data "sysdig_secure_agentless_scanning_assets" "assets" {}

locals {
  suffix = random_id.suffix.hex

  # Full Workload Identity Provider resource name; this is the canonical value Google STS expects as audience
  # (and matches what the host scanning module sends via provider.name).
  wif_provider_name = data.sysdig_secure_agentless_scanning_assets.assets.backend.type == "aws" ? google_iam_workload_identity_pool_provider.agentless[0].name : google_iam_workload_identity_pool_provider.agentless_gcp[0].name
}

resource "random_id" "suffix" {
  byte_length = 3
}

data "sysdig_secure_trusted_cloud_identity" "trusted_identity" {
  cloud_provider = "gcp"
}

resource "google_service_account" "controller" {
  project      = var.project_id
  account_id   = "sysdig-ws-${local.suffix}"
  display_name = "Sysdig Agentless Workload Scanning"
}

resource "google_project_iam_custom_role" "controller" {
  project = var.project_id
  role_id = "${var.role_name}WorkloadController${title(local.suffix)}"
  title   = "Role for Sysdig Agentless Workload Controller"
  permissions = [
    # artifact registry reader permissions
    "artifactregistry.repositories.downloadArtifacts",
    "artifactregistry.repositories.get",
    "artifactregistry.repositories.list",
    "artifactregistry.dockerimages.get",
    "artifactregistry.dockerimages.list",
    "storage.objects.get",
    "storage.buckets.list",
    "storage.objects.list",
  ]
}

resource "google_project_iam_binding" "controller_binding" {
  project = var.project_id
  role    = google_project_iam_custom_role.controller.id

  members = [
    "serviceAccount:${google_service_account.controller.email}",
  ]
}

resource "google_service_account_iam_member" "controller_wif_user" {
  count = data.sysdig_secure_agentless_scanning_assets.assets.backend.type == "aws" ? 1 : 0

  service_account_id = google_service_account.controller.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.agentless.name}/attribute.aws_account/${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id}"
}

resource "google_service_account_iam_member" "controller_wif_token_creator" {
  count = data.sysdig_secure_agentless_scanning_assets.assets.backend.type == "aws" ? 1 : 0

  service_account_id = google_service_account.controller.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.agentless.name}/attribute.aws_account/${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id}"
}

resource "google_service_account_iam_member" "controller_wif_user_gcp" {
  count = data.sysdig_secure_agentless_scanning_assets.assets.backend.type == "gcp" ? 1 : 0

  service_account_id = google_service_account.controller.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.agentless.name}/attribute.sa_id/${data.sysdig_secure_agentless_scanning_assets.assets.backend.cloud_id}"
}

resource "google_service_account_iam_member" "controller_wif_token_creator_gcp" {
  count = data.sysdig_secure_agentless_scanning_assets.assets.backend.type == "gcp" ? 1 : 0

  service_account_id = google_service_account.controller.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.agentless.name}/attribute.sa_id/${data.sysdig_secure_agentless_scanning_assets.assets.backend.cloud_id}"
}

resource "google_iam_workload_identity_pool" "agentless" {
  workload_identity_pool_id = "sysdig-wl-${local.suffix}"
}

resource "google_iam_workload_identity_pool_provider" "agentless" {
  count = data.sysdig_secure_agentless_scanning_assets.assets.backend.type == "aws" ? 1 : 0

  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.agentless.workload_identity_pool_id
  workload_identity_pool_provider_id = "sysdig-wl-${local.suffix}"
  display_name                       = "Sysdig Workload Controller"
  description                        = "AWS identity pool provider for Sysdig Secure Agentless Workload Scanning"
  disabled                           = false

  attribute_condition = "attribute.aws_account==\"${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id}\""

  attribute_mapping = {
    "google.subject"        = "assertion.arn"
    "attribute.aws_account" = "assertion.account"
    "attribute.role"        = "assertion.arn.extract(\"/assumed-role/{role}/\")"
    "attribute.session"     = "assertion.arn.extract(\"/assumed-role/{role_and_session}/\").extract(\"/{session}\")"
  }

  aws {
    account_id = data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id
  }
}

resource "google_iam_workload_identity_pool_provider" "agentless_gcp" {
  count = data.sysdig_secure_agentless_scanning_assets.assets.backend.type == "gcp" ? 1 : 0

  workload_identity_pool_id          = google_iam_workload_identity_pool.agentless.workload_identity_pool_id
  workload_identity_pool_provider_id = "sysdig-wl-${local.suffix}"
  display_name                       = "Sysdig Agentless Workload"
  description                        = "GCP identity pool provider for Sysdig Secure Agentless Workload Scanning"
  disabled                           = false

  attribute_condition = "google.subject == \"${data.sysdig_secure_agentless_scanning_assets.assets.backend.cloud_id}\""

  attribute_mapping = {
    "google.subject"  = "assertion.sub"
    "attribute.sa_id" = "assertion.sub"
  }

  oidc {
    issuer_uri = "https://accounts.google.com"
  }
}

#--------------------------------------------------------------------------------------------------------------
# Call Sysdig Backend to add the service-principal integration for VM Workload Scanning to the Sysdig Cloud Account
#--------------------------------------------------------------------------------------------------------------
resource "sysdig_secure_cloud_auth_account_component" "google_service_principal" {
  account_id = var.sysdig_secure_account_id
  type       = "COMPONENT_SERVICE_PRINCIPAL"
  instance   = "secure-vm-workload-scanning"
  version    = "v0.1.0"
  service_principal_metadata = jsonencode({
    gcp = {
      workload_identity_federation = {
        pool_provider_id = local.wif_provider_name
      }
      email = google_service_account.controller.email
    }
  })
  depends_on = [
    google_service_account.controller,
    google_project_iam_custom_role.controller,
    google_project_iam_binding.controller_binding,
    google_iam_workload_identity_pool.agentless,
    google_iam_workload_identity_pool_provider.agentless,
    google_iam_workload_identity_pool_provider.agentless_gcp,
    google_service_account_iam_member.controller_wif_user,
    google_service_account_iam_member.controller_wif_token_creator,
    google_service_account_iam_member.controller_wif_user_gcp,
    google_service_account_iam_member.controller_wif_token_creator_gcp,
    google_organization_iam_member.controller,
  ]
}
