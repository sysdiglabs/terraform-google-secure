# GCP Agentless Scanning Module

This Module creates the resources required to scan hosts on Google Cloud Projects. Before applying the changes defined
in this module, the following operations need to be performed on the target GCP environment:

- The APIs needed for the VM feature are listed below:
    - Compute Engine API

- The following resources will be created in each instrumented project:
    - For the **Resource Discovery**: Enable Sysdig to authenticate through a Workload Identity Pool (requires provider,
      service account, role, and related bindings)  in order to be able to discover the VPC/Instance/Volumes.
    - For the **Host Data Extraction**: Enable Sysdig to create a disk copy on our SaaS platform, to be able to extract
      the data required for security assessment.

This module will also deploy a Service Principal Component in Sysdig Backend for onboarded Sysdig Cloud Account.

## Single Project Setup

![permission_diagram_single](./permissions_diagram_single.png)

## Organizational Setup

Set `is_organizatinal=true` together with the `organization_domain=<domain>`.
![permission_diagram_org](./permissions_diagram_org.png)

## Requirements

| Name                                                                      | Version   |
|---------------------------------------------------------------------------|-----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0    |
| <a name="requirement_google"></a> [google](#requirement\_google)          | >= 4.21.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig)          | >= 1.34.0 |
| <a name="requirement_random"></a> [random](#requirement\_random)          | >= 3.1    |

## Providers

| Name                                                                      | Version   |
|---------------------------------------------------------------------------|-----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0    |
| <a name="requirement_google"></a> [google](#requirement\_google)          | >= 4.21.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig)          | >= 1.34.0 |
| <a name="requirement_random"></a> [random](#requirement\_random)          | >= 3.1    |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                           | Type        |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [random_id.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id)                                                                          | resource    |
| [google_iam_workload_identity_pool.agentless](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool)                       | resource    |
| [google_iam_workload_identity_pool_provider.agentless](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider)     | resource    |
| [google_iam_workload_identity_pool_provider.agentless_gcp](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource    |
| [google_organization_iam_binding.admin_account_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_binding)                   | resource    |
| [google_organization_iam_binding.controller_custom](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_binding)                   | resource    |
| [google_organization_iam_custom_role.controller](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_custom_role)                  | resource    |
| [google_organization_iam_custom_role.worker_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_custom_role)                 | resource    |
| [google_project_iam_binding.admin_account_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding)                             | resource    |
| [google_project_iam_binding.controller_custom](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding)                             | resource    |
| [google_project_iam_custom_role.controller](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role)                            | resource    |
| [google_project_iam_custom_role.worker_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role)                           | resource    |
| [google_service_account.controller](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account)                                            | resource    |
| [google_service_account_iam_member.controller_custom](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member)               | resource    |
| [google_service_account_iam_member.controller_custom_gcp](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member)           | resource    |
| [google_organization.org](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/organization)                                                      | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project)                                                            | data source |
| [sysdig_secure_trusted_cloud_identity.trusted_identity](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/data-sources/secure_trusted_cloud_identity)      | data source |
| [sysdig_secure_cloud_auth_account_component.gcp_agentless_scan](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/resources/secure_cloud_auth_account_component)             | resource    |

## Inputs

| Name                                                                                                             | Description                                                                                                                                                                                                                                               | Type          | Default | Required |
|------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id)                                               | GCP Project ID                                                                                                                                                                                                                                            | `string`      | n/a     |   yes    |
| <a name="input_is_organizational"></a> [is\_organizational](#input\_is\_organizational)                          | Optional. Determines whether module must scope whole organization. Otherwise single project will be scoped                                                                                                                                                | `bool`        | `false` |    no    |
| <a name="input_organization_domain"></a> [organization\_domain](#input\_organization\_domain)                    | Optional. If `is_organizational=true` is set, its mandatory to specify this value, with the GCP Organization domain. e.g. sysdig.com                                                                                                                      | `string`      | `null`  |    no    |
| <a name="input_sysdig_secure_account_id"></a> [sysdig\_secure\_account\_id](#input\_sysdig\_secure\_account\_id) | ID of the Sysdig Cloud Account to enable Agentless Scanning integration for (in case of organization, ID of the Sysdig management account)                                                                                                                | `string`      | `null`  |    no    |
| <a name="input_suffix"></a> [suffix](#input\_suffix)                                                             | Optional. Suffix word to enable multiple deployments with different naming<br/>(Workload Identity Pool and Providers have a soft deletion on Google Platform that will disallow name re-utilization)<br/>By default a random value will be autogenerated. | `string`      | `null`  |    no    |

## Outputs

| Name                                                                                                         | Description                                                                         |
|--------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|
| <a name="agentless_scan_component_id"></a> [agentless\_scan\_component\_id](#agentless\_scan\_component\_id) | Component identifier of Agentless Scan integration created in Sysdig Backend for VM |

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
