/*
This terraform file is intended to enable the GCP APIs needed for VM feature within a GCP organization onboarding.
It will create a google_project_service resource per each service enabled within each GCP project.
The APIs needed for the VM feature are listed below:
  - Compute Engine API

* Note: This do not overwrite any other APIs config that your GCP project has, it will only enabled it if isn't yet.
*/

# Set local variables for Organization ID and API services to enable
locals {
  organizationID = "933620940614"
  services = [
    "compute.googleapis.com"
  ]
  root_projects = [for project in data.google_projects.organization_projects.projects : project.project_id]
  folder_projects = jsondecode(data.local_file.projects_from_folder.content)
  all_projects = concat(local.root_projects, local.folder_projects)
  project_and_services = flatten([
    for project in local.all_projects : [
      for service in local.services : {
        project = project
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

data "local_file" "projects_from_folder" {
  filename = "project_ids.json"
  depends_on = [null_resource.get_projects_from_folders]
}

# Enable API services for GCP project
resource "google_project_service" "enable_vm_apis" {
  // create a unique key per project and service to enable each API
  for_each = { for item in local.project_and_services : "${item.project}-${item.service}" => item }

  project = each.value.project
  service = each.value.service
  disable_on_destroy = false
}

# Output the projects and APIs enabled
output "enabled_projects" {
  value = distinct([for resource in google_project_service.enable_vm_apis : resource.project])
}

output "enabled_services" {
  value = distinct([for service in google_project_service.enable_vm_apis : service.service])
}


# Script to get projects from folders recursively and set to a file
resource "null_resource" "get_projects_from_folders" {
  provisioner "local-exec" {
    command = <<EOF
    #!/bin/bash
    ORG_ID="933620940614"

    # array to store project IDs
    declare -a FINAL_PROJECT_IDS

    list_projects() {
      local folder_id=$1

      # get projects from folder
      local projects_json=$(gcloud projects list --filter="parent.id=$folder_id AND parent.type=folder" --format=json)

      # check valid array
      if ! echo "$projects_json" | jq empty >/dev/null 2>&1; then
        echo "Invalid JSON returned for projects list."
        return
      fi

      # get project ids
      local project_ids=$(echo "$projects_json" | jq -r '.[] | .projectId')

      # check project ids not empty and add to global variable
      if [ -n "$project_ids" ]; then
        for project_id in $project_ids; do
          FINAL_PROJECT_IDS+=("$project_id")
        done
      else
        echo "No projects found in folder $folder_id"
      fi
    }

    list_folders_recursive() {
      local parent_id=$1
      local parent_type=$2

      # list folders on org or other folders
      if [[ "$parent_type" == "organization" ]]; then
          folders=$(gcloud resource-manager folders list --organization=$parent_id --format=json)
      elif [[ "$parent_type" == "folder" ]]; then
          folders=$(gcloud resource-manager folders list --folder=$parent_id --format=json)
      fi

      # check if there were folders returned
      if [ "$(echo "$folders" | jq length)" -eq 0 ]; then
        return
      fi

      # iterate over folder and call functions recursively
      for folder in $(echo "$folders" | jq -c '.[]'); do
        folder_id=$(echo "$folder" | jq -r '.name' | awk -F'/' '{print $NF}')

        list_projects "$folder_id"
        list_folders_recursive "$folder_id" "folder"
      done
    }

    echo "Listing all projects in folders for organization: $ORG_ID"
    list_folders_recursive "$ORG_ID" "organization"
    printf "%s\n" "$${FINAL_PROJECT_IDS[@]}" | jq -R . | jq -s . > "project_ids.json"
    echo "Projects listed and saved to local file."
    EOF
  }
}