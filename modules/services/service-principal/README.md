# GCP Service Prinicpal Module

This module will deploy a Service Principal (GCP Service Account) for a single GCP project, or for a GCP Organization.

The following resources will be created in each instrumented project:
- A Service Account with associated role permissions to grant Sysdig read only permissions to secure your GCP Project.
    - A Service Account Key attached to this service account using its name. 

If instrumenting a GCP Organization, the service account will be created in the Management Account (provided via the project ID), with appropriate organizational level permissions. 

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.21.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.21.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_service_account.sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account) | resource |
| [google_service_account_key.secure_service_account_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_key) | resource |
| [google_project_iam_member.browser](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_member) | resource |
| [google_project_iam_member.cloudasset_viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_member) | resource |
| [google_project_iam_member.identity_mgmt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_member) | resource |
| [google_organization.org](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/organization) | data source |
| [google_organization_iam_member.browser](https://registry.terraform.io/providers/hashicorp/google/5.0.0/docs/resources/google_organization_iam#google_organization_iam_member) | resource |
| [google_organization_iam_member.cloudasset_viewer](https://registry.terraform.io/providers/hashicorp/google/5.0.0/docs/resources/google_organization_iam#google_organization_iam_member) | resource |
| [google_organization_iam_member.identity_mgmt](https://registry.terraform.io/providers/hashicorp/google/5.0.0/docs/resources/google_organization_iam#google_organization_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The identifier of the GCP project. A service principal will be created in it, to allow Sysdig usage | `string` | n/a | yes |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | The name of the service principal to be created | `string` | `sysdig-secure` | no |
| <a name="input_is_organizational"></a> [is\_organizational](#input\_is\_organizational) | true/false whether secure-for-cloud should be deployed in an organizational setup (all projects of org) or not (only on default gcp provider project) | `bool` | `false` | no |
| <a name="input_organization_domain"></a> [organization\_domain](#input\_organization\_domain) | GCP Organization domain unit id to install posture management | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | Email address of the Service Principal created for Secure Posture Management |
| <a name="output_service_account_key"></a> [service\_account\_key](#output\_service\_account\_key) | Private Key of the Service Principal created for Secure Posture Management |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
