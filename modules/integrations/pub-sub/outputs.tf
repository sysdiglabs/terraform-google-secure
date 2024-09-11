output "pubsub_datasource_component_id" {
  value       = "${sysdig_secure_cloud_auth_account_component.gcp_webhook_datasource.type}/${sysdig_secure_cloud_auth_account_component.gcp_webhook_datasource.instance}"
  description = "Component identifier of Webhook Datasource integration created in Sysdig Backend for Log Ingestion"
  depends_on  = [sysdig_secure_cloud_auth_account_component.gcp_webhook_datasource]
}