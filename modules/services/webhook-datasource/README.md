# GCP Webhook Datasource Module

This Module creates the resources required to send Project-specific AuditLogs to Sysdig by creating a dedicated Push Subscription tied to a ingestion PubSub topic.


The following resources will be created in each instrumented account:
- A Sink to direct the AuditLogs towards a dedicated PubSub topic
- A PubSub ingestion topic that will hold all the AuditLogs coming from the specified project
- A Push Subscription that will POST the AuditLogs collected from the project towards Sysdig's backend
- All the necessary Service Accounts and Policies to enable the AuditLogs publishing operation

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
| [google_logging_project_sink.ingestion_sink](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink) | resource |
| [google_project_iam_audit_config.audit_config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_audit_config) | resource |
| [google_pubsub_subscription.ingestion_topic_push_subscription](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_topic.deadletter_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic.ingestion_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_member.publisher_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |
| [google_service_account.push_auth](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_binding.push_auth_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ack_deadline_seconds"></a> [ack\_deadline\_seconds](#input\_ack\_deadline\_seconds) | (Optional) Maximum time in seconds after Sysdig's subscriber receives a message before the subscriber should acknowledge the message | `number` | `60` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | (Optional) Labels to be associated with Sysdig-originated resources | `map(string)` | <pre>{<br>  "originator": "Sysdig"<br>}</pre> | no |
| <a name="input_max_delivery_attempts"></a> [max\_delivery\_attempts](#input\_max\_delivery\_attempts) | (Optional) Number of attempts redelivering missed messages from the deadletter topic to the main one | `number` | `5` | no |
| <a name="input_maximum_backoff"></a> [maximum\_backoff](#input\_maximum\_backoff) | (Optional) Maximum backoff time for exponential backoff of the push subscription retry policy | `string` | `"600s"` | no |
| <a name="input_message_retention_duration"></a> [message\_retention\_duration](#input\_message\_retention\_duration) | (Optional) How long unacknowledged messages are retained in Sysdig's subscription backlog, from the moment a message is published | `string` | `"604800s"` | no |
| <a name="input_minimum_backoff"></a> [minimum\_backoff](#input\_minimum\_backoff) | (Optional) Minimum backoff time for exponential backoff of the push subscription retry policy | `string` | `"10s"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | (Required) Target Project identifier provided by the customer | `string` | n/a | yes |
| <a name="input_push_endpoint"></a> [push\_endpoint](#input\_push\_endpoint) | (Required) Final endpoint towards which audit logs POST calls will be directed | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | GCP Project Identifier |
| <a name="output_push_endpoint"></a> [push\_endpoint](#output\_push\_endpoint) | Push endpoint towards which the POST request will be directed |
| <a name="output_push_subscription_service_account"></a> [push\_subscription\_service\_account](#output\_push\_subscription\_service\_account) | Service Account used to send POST messages, a KMS key needs to be manually added in order to properly authenticate the requests at Sysdig's side |
