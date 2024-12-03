locals {
  suffix = random_id.suffix.hex
}

resource "random_id" "suffix" {
  byte_length = 3
}

data "google_project" "project" {
  project_id = var.project_id
}

data "sysdig_secure_trusted_cloud_identity" "trusted_identity" {
  cloud_provider = "gcp"
}

data "sysdig_secure_tenant_external_id" "external_id" {}

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

    # workload identity federation
    "iam.serviceAccounts.getAccessToken",
  ]
}

resource "google_project_iam_binding" "controller_binding" {
  project = var.project_id
  role    = google_project_iam_custom_role.controller.id

  members = [
    "serviceAccount:${google_service_account.controller.email}",
  ]
}

resource "google_iam_workload_identity_pool" "agentless" {
  workload_identity_pool_id = "sysdig-wl-${local.suffix}"
}

resource "google_iam_workload_identity_pool_provider" "agentless" {
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

resource "google_service_account_iam_member" "controller_binding" {
  service_account_id = google_service_account.controller.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.agentless.name}/attribute.aws_account/${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id}"
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
        pool_id          = google_iam_workload_identity_pool.agentless.workload_identity_pool_id
        pool_provider_id = google_iam_workload_identity_pool_provider.agentless.workload_identity_pool_provider_id
        project_number   = data.google_project.project.number
      }
      email = google_service_account.controller.email
    }
  })
  depends_on = [
    google_service_account.controller,
    google_project_iam_custom_role.controller,
    google_project_iam_binding.controller_binding,
    google_iam_workload_identity_pool.agentless,
    google_organization_iam_member.controller,
  ]
}
