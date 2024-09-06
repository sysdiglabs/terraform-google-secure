/*
This terraform file is intended to enable the GCP APIs needed for CDR/CIEM feature within a GCP organization onboarding.
It will create a google_project_service resource per each service enabled within each GCP project.
The APIs needed for the CDR/CIEM feature are listed below:
  - Cloud Pub/Sub API

* Note: This do not overwrite any other APIs config that your GCP project has, it will only enabled it if isn't yet.
*/

# Set local variables for Organization ID and API services to enable
locals {
  organizationID = "933620940614"
  services = [
    "pubsub.googleapis.com"
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
resource "google_project_service" "enable_cdr_ciem_apis" {
  // create a unique key per project and service to enable each API
  for_each = { for item in local.project_and_services : "${item.project}-${item.service}" => item }

  project = each.value.project
  service = each.value.service
  disable_on_destroy = false
}

# Output the projects and APIs enabled
output "enabled_projects" {
  value = distinct([for resource in google_project_service.enable_cdr_ciem_apis : resource.project])
}

output "enabled_services" {
  value = distinct([for service in google_project_service.enable_cdr_ciem_apis : service.service])
}