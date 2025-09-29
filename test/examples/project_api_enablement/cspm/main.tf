/*
This terraform file is intended to enable the GCP APIs needed for CSPM feature within a single project onboarding.
It will create a google_project_service resource per each service enabled within the GCP project.
The APIs needed for the CSPM feature are listed below:
  - Cloud Asset API
  - Admin SDK API
In addition, since CSPM is needed for onboard any GCP project these other APIs are also enabled:
  - Identity and access management API
  - IAM Service Account Credentials API
  - Cloud Resource Manager API

* Note: This do not overwrite any other APIs config that your GCP project has, it will only enabled it if isn't yet.
*/

# Set local variables for Project ID and API services to enable
locals {
  project = "<MANAGEMENT_PROJECT_ID>"
  services = [
    # CSPM specific APIs
    "cloudasset.googleapis.com",
    "admin.googleapis.com",

    # additional APIs
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}

# GCP provider
provider "google" {
  project = local.project
  region  = "us-west-1"
}

// Enable API services for GCP project
resource "google_project_service" "enable_cspm_apis" {
  project = local.project

  for_each           = toset(local.services)
  service            = each.value
  disable_on_destroy = false
}

# Output the projects and APIs enabled
output "enabled_projects" {
  value = distinct([for service in local.services : google_project_service.enable_cspm_apis[service].project])
}
output "enabled_services" {
  value = [for service in local.services : google_project_service.enable_cspm_apis[service].service]
}
