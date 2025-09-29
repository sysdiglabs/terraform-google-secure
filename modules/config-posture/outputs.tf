output "service_principal_component_id" {
  value       = "${sysdig_secure_cloud_auth_account_component.google_service_principal.type}/${sysdig_secure_cloud_auth_account_component.google_service_principal.instance}"
  description = "Component identifier of Service Principal created in Sysdig Backend for Config Posture"
  depends_on  = [sysdig_secure_cloud_auth_account_component.google_service_principal]
}
