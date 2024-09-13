#-----------------------------------------------------------------------------------------
# Fetch the data sources
#-----------------------------------------------------------------------------------------
data "sysdig_secure_agentless_scanning_assets" "assets" {}

#-----------------------------------------------------------------------------------------
# These locals indicate the suffix to create unique name for resources and permissions
#-----------------------------------------------------------------------------------------
locals {
  suffix = var.suffix == null ? random_id.suffix[0].hex : var.suffix
  host_discovery_permissions = [
    # networks
    "compute.networks.list",
    "compute.networks.get",
    # instances
    "compute.instances.list",
    "compute.instances.get",
    # disks
    "compute.disks.list",
    "compute.disks.get",
    # workload identity federation
    "iam.serviceAccounts.getAccessToken",
  ]
  host_scan_permissions = [
    # general stuff
    "compute.zoneOperations.get",
    # disks
    "compute.disks.get",
    "compute.disks.useReadOnly",
  ]
}

#-----------------------------------------------------------------------------------------------------------------------
# A random resource is used to generate unique Agentless Scan name suffix for resources.
# This prevents conflicts when recreating an Agentless Scan resources with the same name.
#-----------------------------------------------------------------------------------------------------------------------
resource "random_id" "suffix" {
  count       = var.suffix == null ? 1 : 0
  byte_length = 3
}


resource "google_service_account" "controller" {
  project      = var.project_id
  account_id   = "sysdig-ahs-${local.suffix}"
  display_name = "Sysdig Agentless Host Scanning"
}

#-----------------------------------------------------------------------------------------------------------------------
# Configure Workload Identity Federation for auth
# See https://cloud.google.com/iam/docs/access-resources-aws
#-----------------------------------------------------------------------------------------------------------------------

resource "google_iam_workload_identity_pool" "agentless" {
  workload_identity_pool_id = "sysdig-ahs-${local.suffix}"
}

resource "google_iam_workload_identity_pool_provider" "agentless" {
  count = data.sysdig_secure_agentless_scanning_assets.assets.backend.cloud_id != null ? 1 : 0

  lifecycle {
    precondition {
      condition     = (data.sysdig_secure_agentless_scanning_assets.assets.backend.cloud_id != null && var.sysdig_account_id == null)
      error_message = "Cannot provide both sysdig_backend or sysdig_account_id"
    }
  }

  workload_identity_pool_id          = google_iam_workload_identity_pool.agentless.workload_identity_pool_id
  workload_identity_pool_provider_id = "sysdig-ahs-${local.suffix}"
  display_name                       = "Sysdig Agentless Controller"
  description                        = "AWS identity pool provider for Sysdig Secure Agentless Host Scanning"
  disabled                           = false

  attribute_condition = "attribute.aws_account==\"${data.sysdig_secure_agentless_scanning_assets.assets.backend.cloud_id}\""

  attribute_mapping = {
    "google.subject"        = "assertion.arn"
    "attribute.aws_account" = "assertion.account"
    "attribute.role"        = "assertion.arn.extract(\"/assumed-role/{role}/\")"
    "attribute.session"     = "assertion.arn.extract(\"/assumed-role/{role_and_session}/\").extract(\"/{session}\")"
  }

  aws {
    account_id = data.sysdig_secure_agentless_scanning_assets.assets.backend.cloud_id
  }
}

resource "google_service_account_iam_member" "controller_custom" {
  count = data.sysdig_secure_agentless_scanning_assets.assets.backend.cloud_id != null ? 1 : 0

  lifecycle {
    precondition {
      condition     = (data.sysdig_secure_agentless_scanning_assets.assets.backend.cloud_id != null && var.sysdig_account_id == null)
      error_message = "Cannot provide both sysdig_backend or sysdig_account_id"
    }
  }

  service_account_id = google_service_account.controller.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.agentless.name}/attribute.aws_account/${data.sysdig_secure_agentless_scanning_assets.assets.backend.cloud_id}"
}

resource "google_iam_workload_identity_pool_provider" "agentless_gcp" {
  count = var.sysdig_account_id != null ? 1 : 0

  lifecycle {
    precondition {
      condition     = (data.sysdig_secure_agentless_scanning_assets.assets.backend.cloud_id == null && var.sysdig_account_id != null)
      error_message = "Cannot provide both sysdig_backend or sysdig_account_id"
    }
  }

  workload_identity_pool_id          = google_iam_workload_identity_pool.agentless.workload_identity_pool_id
  workload_identity_pool_provider_id = "sysdig-ahs-${local.suffix}-gcp"
  display_name                       = "Sysdig Agentless Controller"
  description                        = "GCP identity pool provider for Sysdig Secure Agentless Host Scanning"
  disabled                           = false

  attribute_condition = "google.subject == \"${var.sysdig_account_id}\""

  attribute_mapping = {
    "google.subject"  = "assertion.sub"
    "attribute.sa_id" = "assertion.sub"
  }

  oidc {
    issuer_uri = "https://accounts.google.com"
  }
}

resource "google_service_account_iam_member" "controller_custom_gcp" {
  count = var.sysdig_account_id != null ? 1 : 0

  lifecycle {
    precondition {
      condition     = (data.sysdig_secure_agentless_scanning_assets.assets.backend.cloud_id == null && var.sysdig_account_id != null)
      error_message = "Cannot provide both sysdig_backend or sysdig_account_id"
    }
  }

  service_account_id = google_service_account.controller.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.agentless.name}/attribute.sa_id/${var.sysdig_account_id}"
}

#-----------------------------------------------------------------------------------------
# Custom IAM roles and bindings
#-----------------------------------------------------------------------------------------

resource "google_project_iam_custom_role" "controller" {
  count = var.is_organizational ? 0 : 1

  project     = var.project_id
  role_id     = "${var.role_name}Discovery${local.suffix}"
  title       = "${var.role_name}, for Host Discovery"
  permissions = local.host_discovery_permissions
}

resource "google_project_iam_binding" "controller_custom" {
  count = var.is_organizational ? 0 : 1

  project = var.project_id
  role    = google_project_iam_custom_role.controller[0].id
  members = [
    "serviceAccount:${google_service_account.controller.email}",
  ]
}

resource "google_project_iam_custom_role" "worker_role" {
  count = var.is_organizational ? 0 : 1

  project     = var.project_id
  role_id     = "${var.role_name}Scan${local.suffix}"
  title       = "${var.role_name}, for Host Scan"
  permissions = local.host_scan_permissions
}

resource "google_project_iam_binding" "admin_account_iam" {
  count = var.is_organizational ? 0 : 1

  project = var.project_id
  role    = google_project_iam_custom_role.worker_role[0].id
  members = [
    "serviceAccount:${data.sysdig_secure_agentless_scanning_assets.assets.gcp.worker_identity}",
  ]
}

#-----------------------------------------------------------------------------------------------------------------------------------------
# Call Sysdig Backend to add the agentless-scan integration to the Sysdig Cloud Account
#
# Note (optional): To ensure this gets called after all cloud resources are created, add
# explicit dependency using depends_on
#-----------------------------------------------------------------------------------------------------------------------------------------

resource "sysdig_secure_cloud_auth_account_component" "gcp_agentless_scan" {
  account_id = var.sysdig_secure_account_id
  type       = "COMPONENT_SERVICE_PRINCIPAL"
  instance   = "secure-scanning"
  version    = "v0.1.0"
  service_principal_metadata = jsonencode({
    gcp = {
      workload_identity_federation = {
        pool_provider_id = data.sysdig_secure_agentless_scanning_assets.assets.gcp.worker_identity != null ? google_iam_workload_identity_pool_provider.agentless[0].name : var.sysdig_account_id != null ? google_iam_workload_identity_pool_provider.agentless_gcp[0].name : null
      }
      email = google_service_account.controller.email
    }
  })
}
