# GCP Config Posture Module

This module will deploy Config Posture resources in GCP for a single project, or for a GCP Organization.
The Config Posture module serves the following functions:
- retrieving inventory for single project, or for all projects within an Organization.
- retrieving organization metadata in the case of organizational onboarding within GCP Organization.

If instrumenting a project, the following resources will be created:
- All the necessary `Service Accounts` and `Policies` to enable the Config posture operation at the project level
- A `Workload Identity Pool`, `Provider` and added custom role permissions to the `Service Account`, to allow Sysdig to authenticate to GCP on your behalf to validate resources.
- A cloud account component in the Sysdig Backend, associated with the GCP project and with the required component to serve the config posture functions.

If instrumenting an Organziation, the following resources will be created:
- All the necessary `Service Accounts` and `Policies` to enable the Config Posture operation at the organization level
- A `Workload Identity Pool`, `Provider` and added custom role permissions to the `Service Account`, to allow Sysdig to authenticate to GCP on your behalf to validate resources.
- A cloud account component in the Sysdig Backend, associated with the GCP project and with the required component to serve the config posture functions.

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

| [google_service_account.posture_auth](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_organization.org](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/organization) | data source |
| [sysdig_secure_trusted_cloud_identity.trusted_identity](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/data-sources/secure_trusted_cloud_identity) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [sysdig_secure_tenant_external_id](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/data-sources/secure_tenant_external_id) | data source |
| [random_id.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google_iam_workload_identity_pool.posture_auth_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool) | resource |
| [google_iam_workload_identity_pool_provider.posture_auth_pool_provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_project_iam_member.cspm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_member) | resource |
| [google_service_account_iam_member.custom_posture_auth](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam#google_service_account_iam_member) | resource |
| [google_organization_iam_member.cspm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_organization_iam#google_organization_iam_member) | resource |
| [sysdig_secure_cloud_auth_account_component.google_service_principal](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/resources/secure_cloud_auth_account_component) | resource |

## Inputs

| Name                                                                                                             | Description                                                                                                               | Type | Default                                       | Required |
|------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------|------|-----------------------------------------------|:--------:|
| <a name="input_is_organizational"></a> [is\_organizational](#input\_is\_organizational)                          | (Optional) Set this field to 'true' to deploy secure-for-cloud to a GCP Organization.                                     | `bool` | `false`                                       |    no    |
| <a name="input_organization_domain"></a> [organization\_domain](#input\_organization\_domain)                    | Organization domain. e.g. sysdig.com                                                                                      | `string` | `""`                                          |    no    |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id)                                               | (Required) Target Project identifier provided by the customer                                                             | `string` | n/a                                           |   yes    |
| <a name="input_suffix"></a> [suffix](#input\_suffix)                                                             | (Optional) Suffix to uniquely identify resources during multiple installs. If not provided, random value is autogenerated | `string` | `null`                                        |    no    |
| <a name="input_sysdig_secure_account_id"></a> [sysdig\_secure\_account\_id](#input\_sysdig\_secure\_account\_id) | (Required) The GUID of the management project or single project per sysdig representation                                 | `string` | n/a                                           |   yes    |

## Outputs

| Name                                                                                                                                 | Description                                                                    |
|--------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------|
| <a name="output_service_principal_component_id"></a> [service\_principal\_component\_id](#output\_service\_principal\_component\_id) | The component id of the config posture service principal with its WIF metadata |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.