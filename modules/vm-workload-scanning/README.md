# GCP VM Workload Scanning Module

This Module creates the resources required to perform agentless workload scanning operations in Google Cloud Platform (GCP). It sets up the necessary roles, service accounts, and workload identity providers to enable Sysdig to scan workloads running in GCP projects.

By default, it will create a service account with permissions necessary to access and access GAR and GCR repositories and pull their images.

The following resources will be created in each instrumented project:
- A Service Account and associated roles that allow Sysdig to perform tasks necessary for VM agentless workload scanning, i.e., access GAR/GCR repositories and pull its images.
- A Workload Identity Provider to facilitate secure authentication between GCP and Sysdig.

### Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.7 |
| google | >= 4.50.0 |
| sysdig | ~> 3.3    |

### Providers

| Name | Version |
|------|---------|
| google | >= 4.50.0 |
| sysdig | ~> 3.3    |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| google_service_account.controller | resource |
| google_project_iam_member.controller | resource |
| google_iam_workload_identity_pool.agentless | resource |
| google_iam_workload_identity_pool_provider.agentless | resource |
| google_iam_workload_identity_pool.agentless_gcp | resource |
| google_iam_workload_identity_pool_provider.agentless_gcp | resource |
| google_project.project | data source |

### Inputs

| Name                                                                      | Description                                                                                                                      | Type          | Default                       | Required |
|---------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|---------------|-------------------------------|:--------:|
| project_id                                                                | GCP Project ID                                                                                                                   | string        | n/a                           |   yes    |
| is_organizational                                                         | Set this field to 'true' to deploy workload scanning to a GCP Organization.                                                      | bool          | false                         |    no    |
| organization_domain                                                       | (Optional) Organization domain. e.g. sysdig.com                                                                                  | string        | ""                            |    no    |
| role_name                                                                 | Name for the Worker Role on the Customer infrastructure                                                                          | string        | "SysdigAgentlessWorkloadRole" |    no    |
| sysdig_secure_account_id                                                  | ID of the Sysdig Cloud Account to enable VM Workload Scanning for (in case of organization, ID of the Sysdig management account) | string        | n/a                           |   yes    |

### Outputs

| Name | Description |
|------|-------------|
| vm_workload_scanning_component_id | Component identifier of service principal created in Sysdig Backend for VM Workload Scanning |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
