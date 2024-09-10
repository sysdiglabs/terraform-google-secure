# GCP Webhook Datasource Module

This Module creates the resources required to send AuditLogs logs to Sysdig via GCP Pub Subscription. These resources enable Threat Detection in the given GCP project or organization.
Before applying the changes defined in this module, the following operations need to be performed on the target GCP environment:

- The APIs needed for the CDR/CIEM feature are listed below:
    - Cloud Pub/Sub API

- The following resources will be created in each instrumented project:
    - A `PubSub Topic` to send the AuditLogs from the project
    - A `Logging Sink` that export AuditLogs to the PubSub topic
    - A `PubSub Topic IAM member` to assign a role to the PubSub topic
    - A `PubSub Subscription` to allows receiving messages from the PubSub topic, including its `Service Account`
    - An `IAM Workload Identity Pool` that enables identities from external systems(AWS) tp access GCP resources through IAM
    - An `IAM role and member` that provides the required permissions for Sysdig Backend to read cloud resources created for data ingestion

When run in organizational mode, this module is similar however the main difference is that an organizational sink is used
instead of a project-specific one, as well as enabling AuditLogs for all the projects that fall within the organization.

This module will also deploy a Webhook Datasource Component in Sysdig Backend for onboarded Sysdig Cloud Account.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name                                                                      | Version   |
|---------------------------------------------------------------------------|-----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0  |
| <a name="requirement_google"></a> [google](#requirement\_google)          | >= 4.21.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig)          |           |

## Providers

| Name                                                             | Version   |
|------------------------------------------------------------------|-----------|
| <a name="provider_google"></a> [google](#provider\_google)       | >= 4.21.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1    |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) |           |


## Modules

No modules.

## Resources

| Name                                                                                                                                                                                                 | Type        |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [random_id.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id)                                                                                                | resource    |
| [google_project_iam_audit_config.audit_config](https://registry.terraform.io/providers/hashicorp/google/3.0.0-beta.1/docs/resources/google_project_iam#google_project_iam_audit_config)              | resource    |
| [google_pubsub_topic.ingestion_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic.html)                                                              | resource    |
| [google_pubsub_topic.deadletter_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic.html)                                                             | resource    |
| [google_logging_project_sink.ingestion_sink](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink)                                                    | resource    |
| [google_pubsub_topic_iam_member.publisher_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam#google_pubsub_topic_iam_member)                | resource    |
| [google_service_account.push_auth](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account)                                                            | resource    |
| [google_service_account_iam_binding.push_auth_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam#google_service_account_iam_binding) | resource    |
| [google_pubsub_subscription.ingestion_topic_push_subscription](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription.html)                              | resource    |
| [google_iam_workload_identity_pool.ingestion_auth_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool)                                   | resource    |
| [google_iam_workload_identity_pool_provider.ingestion_auth_pool_provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider)        | resource    |
| [google_project_iam_custom_role.custom_ingestion_auth_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam_custom_role)                           | resource    |
| [google_project_iam_member.custom](https://registry.terraform.io/providers/hashicorp/google/3.22.0/docs/resources/google_project_iam#google_project_iam_member)                                      | resource    |
| [google_service_account_iam_member.custom_auth](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam#google_service_account_iam_member)         | resource    |
| [sysdig_secure_trusted_cloud_identity.trusted_identity](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/data-sources/secure_trusted_cloud_identity)                            | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project)                                                                                  | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ack_deadline_seconds"></a> [ack\_deadline\_seconds](#input\_ack\_deadline\_seconds) | (Optional) Maximum time in seconds after Sysdig's subscriber receives a message before the subscriber should acknowledge the message | `number` | `60` | no |
| <a name="input_is_organizational"></a> [is\_organizational](#input\_is\_organizational) | (Optional) Set this field to 'true' to deploy secure-for-cloud to a GCP Organization. | `bool` | `false` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | (Optional) Labels to be associated with Sysdig-originated resources | `map(string)` | <pre>{<br>  "originator": "sysdig"<br>}</pre> | no |
| <a name="input_max_delivery_attempts"></a> [max\_delivery\_attempts](#input\_max\_delivery\_attempts) | (Optional) Number of attempts redelivering missed messages from the deadletter topic to the main one | `number` | `5` | no |
| <a name="input_maximum_backoff"></a> [maximum\_backoff](#input\_maximum\_backoff) | (Optional) Maximum backoff time for exponential backoff of the push subscription retry policy | `string` | `"600s"` | no |
| <a name="input_message_retention_duration"></a> [message\_retention\_duration](#input\_message\_retention\_duration) | (Optional) How long unacknowledged messages are retained in Sysdig's subscription backlog, from the moment a message is published | `string` | `"604800s"` | no |
| <a name="input_minimum_backoff"></a> [minimum\_backoff](#input\_minimum\_backoff) | (Optional) Minimum backoff time for exponential backoff of the push subscription retry policy | `string` | `"10s"` | no |
| <a name="input_organization_domain"></a> [organization\_domain](#input\_organization\_domain) | Organization domain. e.g. sysdig.com | `string` | `""` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | (Required) Target Project identifier provided by the customer | `string` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | (Optional) Role name for custom role binding to the service account, with read permissions for data ingestion resources | `string` | `"SysdigIngestionAuthRole"` | no |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | (Optional) Suffix to uniquely identify resources during multiple installs. If not provided, random value is autogenerated | `string` | `null` | no |
| <a name="input_audit_log_config"></a> [audit\_log\_config](#input\_audit\_log\_config) | List of services and their audit log configurations to be ingested. Default is to ingest all logs. | <pre>list(object({<br>    service = string,<br>    log_config = list(object({<br>      log_type         = string,<br>      exempted_members = optional(list(string))<br>    }))<br>  }))</pre> | <pre>[<br>  {<br>    "log_config": [<br>      {<br>        "log_type": "ADMIN_READ"<br>      },<br>      {<br>        "log_type": "DATA_READ"<br>      },<br>      {<br>        "log_type": "DATA_WRITE"<br>      }<br>    ],<br>    "service": "allServices"<br>  }<br>]</pre> | no |
| <a name="ingestion_sink_filter"></a> [ingestion\_sink\_filter](#input\_ingestion\_sink\_filter) | Filter the Sink is set up with. Ingests AuditLogs by default. | `string` | `protoPayload.@type = "type.googleapis.com/google.cloud.audit.AuditLog"` | no |
| <a name="input_exclude_logs_filter"></a> [exclude\_logs\_filter](#input\_exclude\_logs\_filter) | Filter to exclude logs from ingestion. Default is to ingest all google.cloud.audit.AuditLog logs. with no exclusions. | <pre>list(object({<br>    name        = string,<br>    description = optional(string),<br>    filter      = string,<br>    disabled    = optional(bool)<br>  }))</pre> | `[]` | no |

## Outputs

| Name                                                                                                                            | Description                                                                                        |
|---------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------|
| <a name="output_webhook_datasource_component_id"></a> [webhook\_datasource\_component\_id](#webhook\_datasource\_component\_id) | Component identifier of Webhook Datasource integration created in Sysdig Backend for Log Ingestion |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
