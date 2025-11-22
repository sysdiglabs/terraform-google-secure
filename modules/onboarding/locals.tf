locals {
  # add 'folders/' prefix to the include/exclude folders
  prefixed_include_folders = [for folder_id in var.include_folders : "folders/${folder_id}"]
  prefixed_exclude_folders = [for folder_id in var.exclude_folders : "folders/${folder_id}"]

  # fetch the GCP root org
  root_org = var.is_organizational ? [data.google_organization.org[0].name] : []
}

