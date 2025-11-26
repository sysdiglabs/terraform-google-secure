/*
This terraform file is intended to enable the GCP APIs needed for CDR/CIEM feature within a single project onboarding.
It will create a google_project_service resource per each service enabled within the GCP project.
The APIs needed for the CDR/CIEM feature are listed below:
  - Cloud Pub/Sub API
  - Cloud Logging API
  - Cloud Monitoring API

* Note: This do not overwrite any other APIs config that your GCP project has, it will only enabled it if isn't yet.
*/

# Set local local variables for Project ID and API services to enable
locals {
  project = "<MANAGEMENT_PROJECT_ID>"
  services = [
    "pubsub.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

# GCP provider
provider "google" {
  project = local.project
  region  = "us-west-1"
}

// Enable API services for GCP project
resource "google_project_service" "enable_cdr_ciem_apis" {
  project = local.project

  for_each           = toset(local.services)
  service            = each.value
  disable_on_destroy = false
}

# Output the projects and APIs enabled
output "enabled_projects" {
  value = distinct([for service in local.services : google_project_service.enable_cdr_ciem_apis[service].project])
}
output "enabled_services" {
  value = [for service in local.services : google_project_service.enable_cdr_ciem_apis[service].service]
}
