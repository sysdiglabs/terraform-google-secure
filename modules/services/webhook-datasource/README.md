# GCP Webhook Datasource Module

This Module creates the resources required to send Project or Organization-specific AuditLogs to Sysdig by creating a dedicated Push Subscription tied to a ingestion PubSub topic.


The following resources will be created in each instrumented account:
- A Project/Organization `Sink` to direct the AuditLogs towards a dedicated PubSub topic
- A `PubSub` ingestion topic that will hold all the AuditLogs coming from the specified project
- A `Push` Subscription that will POST the AuditLogs collected from the project towards Sysdig's backend
- All the necessary `Service Accounts` and `Policies` to enable the `AuditLogs` publishing operation
- A `Workload Identity Pool`, `Provider` and added custom role permissions to the `Service Account`, to allow Sysdig to authenticate to GCP on your behalf to validate resources.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.21.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | ~> 3.3    |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_logging_organization_sink.ingestion_sink](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_organization_sink) | resource |
| [google_logging_project_sink.ingestion_sink](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink) | resource |
| [google_organization_iam_audit_config.audit_config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_audit_config) | resource |
| [google_project_iam_audit_config.audit_config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_audit_config) | resource |
| [google_pubsub_subscription.ingestion_topic_push_subscription](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_topic.deadletter_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic.ingestion_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_member.publisher_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |
| [google_service_account.push_auth](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_binding.push_auth_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |
| [google_organization.org](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/organization) | data source |
| [sysdig_secure_trusted_cloud_identity.trusted_identity](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/data-sources/secure_trusted_cloud_identity) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [random_id.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google_iam_workload_identity_pool.ingestion_auth_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool) | resource |
| [google_iam_workload_identity_pool_provider.ingestion_auth_pool_provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_project_iam_custom_role.custom_ingestion_auth_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam_custom_role) | resource |
| [google_project_iam_member.custom](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_member) | resource |
| [google_service_account_iam_member.custom_auth](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam#google_service_account_iam_member) | resource |
| [google_organization_iam_custom_role.custom_ingestion_auth_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_organization_iam_custom_role) | resource |
| [google_organization_iam_member.custom](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_organization_iam#google_organization_iam_member) | resource |

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
| <a name="input_push_endpoint"></a> [push\_endpoint](#input\_push\_endpoint) | (Required) Final endpoint towards which audit logs POST calls will be directed | `string` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | (Optional) Role name for custom role binding to the service account, with read permissions for data ingestion resources | `string` | `"SysdigIngestionAuthRole"` | no |
| <a name="input_external_id"></a> [external\_id](#input\_external\_id) | (Required) Random string generated unique to a customer | `string` | n/a | yes |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | (Optional) Suffix to uniquely identify resources during multiple installs. If not provided, random value is autogenerated | `string` | `null` | no |
| <a name="input_audit_log_config"></a> [audit\_log\_config](#input\_audit\_log\_config) | List of services and their audit log configurations to be ingested. Default is to ingest all logs. | <pre>list(object({<br>    service = string,<br>    log_config = list(object({<br>      log_type         = string,<br>      exempted_members = optional(list(string))<br>    }))<br>  }))</pre> | <pre>[<br>  {<br>    "log_config": [<br>      {<br>        "log_type": "ADMIN_READ"<br>      },<br>      {<br>        "log_type": "DATA_READ"<br>      },<br>      {<br>        "log_type": "DATA_WRITE"<br>      }<br>    ],<br>    "service": "allServices"<br>  }<br>]</pre> | no |
| <a name="ingestion_sink_filter"></a> [ingestion\_sink\_filter](#input\_ingestion\_sink\_filter) | Filter the Sink is set up with. Ingests AuditLogs by default. | `string` | `protoPayload.@type = "type.googleapis.com/google.cloud.audit.AuditLog"` | no |
| <a name="input_exclude_logs_filter"></a> [exclude\_logs\_filter](#input\_exclude\_logs\_filter) | Filter to exclude logs from ingestion. Default is to ingest all google.cloud.audit.AuditLog logs. with no exclusions. | <pre>list(object({<br>    name        = string,<br>    description = optional(string),<br>    filter      = string,<br>    disabled    = optional(bool)<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_push_endpoint"></a> [push\_endpoint](#output\_push\_endpoint) | Push endpoint towards which the POST request will be directed |
| <a name="output_ingestion_pubsub_topic_name"></a> [ingestion\_pubsub\_topic\_name](#output\_ingestion\_pubsub\_topic\_name) | PubSub ingestion topic that will hold all the AuditLogs coming from the specified project |
| <a name="output_ingestion_sink_name"></a> [ingestion\_sink\_name](#output\_ingestion\_sink\_name) | Project/Organization sink to direct the AuditLogs towards a dedicated PubSub topic |
| <a name="output_ingestion_push_subscription_name"></a> [ingestion\_push\_subscription\_name](#output\_ingestion\_push\_subscription\_name) | Push Subscription that will POST the AuditLogs collected from the project towards Sysdig's backend |
| <a name="output_workload_identity_pool_id"></a> [workload\_identity\_pool\_id](#output\_workload\_identity\_pool\_id) | Id of Workload Identity Pool for authenticating to GCP to access data ingestion resources |
| <a name="output_workload_identity_pool_provider_id"></a> [workload\_identity\_pool\_provider\_id](#output\_workload\_identity\_pool\_provider\_id) | Id of Workload Identity Pool Provider for authenticating to GCP to access data ingestion resources |
| <a name="output_workload_identity_project_number"></a> [workload\_identity\_project\_number](#output\_workload\_identity\_project\_number) | GCP project number |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | email of the Service Account created |
