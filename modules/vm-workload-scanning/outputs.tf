output "vm_workload_scanning_component_id" {
  value       = "${sysdig_secure_cloud_auth_account_component.google_service_principal.type}/${sysdig_secure_cloud_auth_account_component.google_service_principal.instance}"
  description = "Component identifier of service principal created in Sysdig Backend for VM Workload Scanning"
  depends_on  = [sysdig_secure_cloud_auth_account_component.google_service_principal]
}
