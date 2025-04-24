# GCP Onboarding Module

This module will deploy Foundational Onboarding resources in GCP for a single project, or for a GCP Organization.
The Foundational Onboarding module serves the following functions:
- retrieving inventory for single project, or for all projects within an Organization.
- running organization scraping in the case of organizational onboarding within GCP Organization.

If instrumenting a project, the following resources will be created:
- All the necessary `Service Accounts` and `Policies` to enable the Onboarding operation at the project level
- A `Service Account key` and added role permissions to the `Service Account`, to allow Sysdig to authenticate to GCP on your behalf to validate resources.
- A cloud account in the Sysdig Backend, associated with the GCP project and with the required component to serve the foundational functions.

If instrumenting an Organziation, the following resources will be created:
- All the necessary `Service Accounts` and `Policies` to enable the Onboarding operation at the organization level
- A `Service Account key` and added role permissions to the `Service Account`, to allow Sysdig to authenticate to GCP on your behalf to validate resources.
- A cloud account in the Sysdig Backend, associated with the management project and with the required component to serve the foundational functions.
- A cloud organization in the Sysdig Backend, associated with the GCP Organization to fetch the organization structure to install Sysdig Secure for Cloud on.

Note:
- The outputs from the foundational module, such as `sysdig_secure_account_id` are needed as inputs to the other features/integrations modules for subsequent modular installs.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version   |
|------|-----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0  |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.21.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 1.34.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1 |

## Modules

No modules.

## Resources

| [google_service_account.onboarding_auth](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_organization.org](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/organization) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [random_id.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google_project_iam_member.browser](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_member) | resource |
| [google_organization_iam_member.browser](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_organization_iam#google_organization_iam_member) | resource |
| [google_service_account_key.onboarding_service_account_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [sysdig_secure_cloud_auth_account.google_account](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/resources/secure_cloud_auth_account) | resource |
| [sysdig_secure_organization.google_organization](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/resources/secure_organization) | resource |

## Inputs

| Name                                                                                          | Description                                                                                                                                                                             | Type          | Default | Required |
|-----------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|---------|:--------:|
| <a name="input_is_organizational"></a> [is\_organizational](#input\_is\_organizational)       | (Optional) Set this field to 'true' to deploy secure-for-cloud to a GCP Organization.                                                                                                   | `bool`        | `false` |    no    |
| <a name="input_organization_domain"></a> [organization\_domain](#input\_organization\_domain) | Organization domain. e.g. sysdig.com                                                                                                                                                    | `string`      | `""`    |    no    |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id)                            | (Required) Target Project identifier provided by the customer                                                                                                                           | `string`      | n/a     |   yes    |
| <a name="input_suffix"></a> [suffix](#input\_suffix)                                          | (Optional) Suffix to uniquely identify resources during multiple installs. If not provided, random value is autogenerated                                                               | `string`      | `null`  |    no    |
| <a name="input_management_group_ids"></a> [suffix](#input\_management\_group\_ids)            | TO BE DEPRECATED: Please work with Sysdig to migrate to using `include_folders` instead.<br>List of management group ids w.r.t an org install. If not provided, set to empty by default | `set(string)` | `[]`    |    no    |
| <a name="input_include_folders"></a> [suffix](#input\_include\_folders)                       | folders to include for organization in the format 'folders/{folder_id}'. i.e: folders/123456789012                                                                                      | `set(string)` | `[]`    |    no    |
| <a name="input_exclude_folders"></a> [suffix](#input\_exclude\_folders)                       | folders to exclude for organization in the format 'folders/{folder_id}'. i.e: folders/123456789012                                                                                      | `set(string)` | `[]`    |    no    |
| <a name="input_include_projects"></a> [suffix](#input\_include\_projects)                     | projects to include for organization. i.e: my-project-id                                                                                                                                | `set(string)` | `[]`    |    no    |
| <a name="input_exclude_projects"></a> [suffix](#input\_exclude\_projects)                     | projects to exclude for organization. i.e: my-project-id                                                                                                                                | `set(string)` | `[]`    |    no    |



## Outputs

| Name                                                                                                               | Description                                                                                    |
|--------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------|
| <a name="output_sysdig_secure_account_id"></a> [sysdig\_secure\_account\_id](#output\_sysdig\_secure\_account\_id) | ID of the Sysdig Cloud Account created                                                         |
| <a name="output_is_organizational"></a> [is\_organizational](#output\_is\_organizational)                          | Boolean value to indicate if secure-for-cloud is deployed to an entire GCP organization or not |
| <a name="output_organization_domain"></a> [organization\_domain](#output\_organization\_domain)                    | Organization domain of the GCP org being onboarded                                             |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id)                                               | The management project id chosen during install, where global resources are deployed           |
| <a name="output_include_folders"></a> [suffix](#output\_include\_folders)                                          | folders to include for organization                                                            |
| <a name="output_exclude_folders"></a> [suffix](#output\_exclude\_folders)                                          | folders to exclude for organization                                                            |
| <a name="output_include_projects"></a> [suffix](#output\_include\_projects)                                        | projects to include for organization                                                           |
| <a name="output_exclude_projects"></a> [suffix](#output\_exclude\_projects)                                        | projects to exclude for organization                                                           |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.