output "pubsub_datasource_component_id" {
  value       = "${sysdig_secure_cloud_auth_account_component.gcp_pubsub_datasource.type}/${sysdig_secure_cloud_auth_account_component.gcp_pubsub_datasource.instance}"
  description = "Component identifier of Webhook Datasource integration created in Sysdig Backend for Log Ingestion"
  depends_on  = [sysdig_secure_cloud_auth_account_component.gcp_pubsub_datasource]
}

output "component_ready" {
  value       = time_sleep.wait_for_component_readiness
  description = "Wait handle to ensure component is fully registered before creating features"
}

output "post_ciem_basic_delay" {
  value       = var.wait_after_basic_seconds > 0 ? time_sleep.wait_after_ciem_basic : null
  description = "Wait handle to delay downstream operations after basic by the configured seconds."
}
