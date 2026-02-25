output "vm_workload_scanning_component_id" {
  value       = "${sysdig_secure_cloud_auth_account_component.google_service_principal.type}/${sysdig_secure_cloud_auth_account_component.google_service_principal.instance}"
  description = "Component identifier of service principal created in Sysdig Backend for VM Workload Scanning"
  depends_on  = [sysdig_secure_cloud_auth_account_component.google_service_principal]
}

output "component_ready" {
  value       = time_sleep.wait_for_component_readiness
  description = "Wait handle to ensure component is fully registered before creating features"
}
