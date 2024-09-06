/*
This terraform file is intended to enable the GCP APIs needed for CSPM feature within a GCP organization onboarding.
It will create a google_project_service resource per each service enabled within each GCP project.
The APIs needed for the CSPM feature are listed below:
  - Security Token Service API
  - Cloud Asset API
  - Cloud Identity API
  - Admin SDK API
In addition, since CSPM is needed for onboard any GCP project these other APIs are also enabled:
  - Identity and access management API
  - IAM Service Account Credentials API
  - Cloud Resource Manager API

* Note: This do not overwrite any other APIs config that your GCP project has, it will only enabled it if isn't yet.
*/

# Set local variables for Organization ID and API services to enable
locals {
  organizationID = "933620940614"
  services = [
    # CSPM specific APIs
    "sts.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudidentity.googleapis.com",
    "admin.googleapis.com",

    # additional APIs
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
  project_and_services = flatten([
    for project in data.google_projects.organization_projects.projects : [
      for service in local.services : {
        project = project.project_id
        service = service
      }
    ]
  ])
}

# GCP provider
provider "google" {
  region      = "us-west-1"
}

# Get list of projects under the specified organization
data "google_projects" "organization_projects" {
   filter = "parent.type:organization parent.id:${local.organizationID}"
}

# Enable API services for GCP project
resource "google_project_service" "enable_cspm_apis" {
  // create a unique key per project and service to enable each API
  for_each = { for item in local.project_and_services : "${item.project}-${item.service}" => item }

  project = each.value.project
  service = each.value.service
  disable_on_destroy = false
}

# Output the projects and APIs enabled
output "enabled_projects" {
  value = distinct([for resource in google_project_service.enable_cspm_apis : resource.project])
}

output "enabled_services" {
  value = distinct([for service in google_project_service.enable_cspm_apis : service.service])
}