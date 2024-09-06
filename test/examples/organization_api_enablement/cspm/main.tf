# /*
# This terraform file is intended to enable the GCP APIs needed for CSPM feature within an organization onboarding.
# It will create a google_project_service resource per each service enabled within each GCP project.
# The APIs needed for the CSPM feature are listed below:
#   - Security Token Service API
#   - Cloud Asset API
#   - Cloud Identity API
#   - Admin SDK API
# In addition, since CSPM is needed for onboard any GCP project these other APIs are also enabled:
#   - Identity and access management API
#   - IAM Service Account Credentials API
#   - Cloud Resource Manager API
#
# * Note: This do not overwrite any other APIs config that your GCP project has, it will only enabled it if isn't yet.
# */
#
# # Set local variables for Organization ID and API services to enable
# locals {
#   organization = "933620940614"
#   services = [
#     # CSPM specific APIs
#     "sts.googleapis.com",
#     "cloudasset.googleapis.com",
#     "cloudidentity.googleapis.com",
#     "admin.googleapis.com",
#
#     # additional APIs
#     "iam.googleapis.com",
#     "iamcredentials.googleapis.com",
#     "cloudresourcemanager.googleapis.com"
#   ]
# }
#
# # GCP provider
# provider "google" {
# #   project     = local.project
#   region      = "us-west-1"
# }
#
# # Get list of projects under the specified organization
# data "google_projects" "organization_projects" {
# #   filter = "parent.type:organization parent.id:${local.organization}"
# }
#
# output "org_projects" {
#   value = data.google_projects.organization_projects
# }
#
#
# # // Enable API services for GCP project
# # resource "google_project_service" "enable_cdr_ciem_apis" {
# #   project  = local.project
# #
# #   for_each = toset(local.services)
# #   service = each.value
# #   # TODO: Question? Leave a note to user that APIs will keep enabled when running a TF destroy here, makes sense?
# #   disable_on_destroy = false
# # }
# #
# # # Output the projects and APIs enabled
# # output "enabled_projects" {
# #   value = distinct([for service in local.services : google_project_service.enable_cdr_ciem_apis[service].project])
# # }
# # output "enabled_services" {
# #   value = [for service in local.services : google_project_service.enable_cdr_ciem_apis[service].service]
# # }