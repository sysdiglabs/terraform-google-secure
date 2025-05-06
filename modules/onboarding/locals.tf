locals {
  # check if both old and new include/exclude org parameters are used, we fail early
  both_org_configuration_params = var.is_organizational && length(var.management_group_ids) > 0 && (
    length(var.include_folders) > 0 ||
    length(var.exclude_folders) > 0 ||
    length(var.include_projects) > 0 ||
    length(var.exclude_projects) > 0
  )

  # check if old management_group_ids parameter is provided, for backwards compatibility we will always give preference to it
  check_old_management_group_ids_param = var.is_organizational && length(var.management_group_ids) > 0

  # fetch the GCP root org
  root_org = var.is_organizational ? [data.google_organization.org[0].name] : []
}

check "validate_org_configuration_params" {
  assert {
    condition     = length(var.management_group_ids) == 0 # if this condition is false we throw warning
    error_message = <<-EOT
    WARNING: TO BE DEPRECATED 'management_group_ids' on 30th November, 2025. Please work with Sysdig to migrate your Terraform installs to use 'include_folders' instead.
    EOT
  }

  assert {
    condition     = !local.both_org_configuration_params # if this condition is false we throw error
    error_message = <<-EOT
    ERROR: If both management_group_ids and include_folders/exclude_folders/include_projects/exclude_projects variables are populated,
    ONLY management_group_ids will be considered. Please use only one of the two methods.

    Note: management_group_ids is going to be DEPRECATED 'management_group_ids' on 30th November, 2025. Please work with Sysdig to migrate your Terraform installs.
    EOT
  }
}