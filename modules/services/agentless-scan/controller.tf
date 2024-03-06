resource "google_service_account" "controller" {
  project      = var.project_id
  account_id   = "sysdig-ahs-${local.suffix}"
  display_name = "Sysdig Agentless Host Scanning"
}

resource "google_iam_workload_identity_pool" "agentless" {
  workload_identity_pool_id = "sysdig-ahs-${local.suffix}"
}

resource "google_iam_workload_identity_pool_provider" "agentless" {
  count = var.sysdig_backend != null ? 1 : 0

  lifecycle {
    precondition {
      condition     = (var.sysdig_backend != null && var.sysdig_account_id == null)
      error_message = "Cannot provide both sysdig_backend or sysdig_account_id"
    }
  }

  workload_identity_pool_id          = google_iam_workload_identity_pool.agentless.workload_identity_pool_id
  workload_identity_pool_provider_id = "sysdig-ahs-${local.suffix}"
  display_name                       = "Sysdig Agentless Controller"
  description                        = "AWS identity pool provider for Sysdig Secure Agentless Host Scanning"
  disabled                           = false

  attribute_condition = "attribute.aws_account==\"${var.sysdig_backend}\""

  attribute_mapping = {
    "google.subject"        = "assertion.arn"
    "attribute.aws_account" = "assertion.account"
    "attribute.role"        = "assertion.arn.extract(\"/assumed-role/{role}/\")"
    "attribute.session"     = "assertion.arn.extract(\"/assumed-role/{role_and_session}/\").extract(\"/{session}\")"
  }

  aws {
    account_id = var.sysdig_backend
  }
}

resource "google_service_account_iam_member" "controller_custom" {
  count = var.sysdig_backend != null ? 1 : 0

  lifecycle {
    precondition {
      condition     = (var.sysdig_backend != null && var.sysdig_account_id == null)
      error_message = "Cannot provide both sysdig_backend or sysdig_account_id"
    }
  }

  service_account_id = google_service_account.controller.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.agentless.name}/attribute.aws_account/${var.sysdig_backend}"
}

resource "google_iam_workload_identity_pool_provider" "agentless_gcp" {
  count = var.sysdig_account_id != null ? 1 : 0

  lifecycle {
    precondition {
      condition     = (var.sysdig_backend == null && var.sysdig_account_id != null)
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
      condition     = (var.sysdig_backend == null && var.sysdig_account_id != null)
      error_message = "Cannot provide both sysdig_backend or sysdig_account_id"
    }
  }

  service_account_id = google_service_account.controller.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.agentless.name}/attribute.sa_id/${var.sysdig_account_id}"
}
