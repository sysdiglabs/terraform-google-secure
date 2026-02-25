output "agentless_scan_component_id" {
  value       = "${sysdig_secure_cloud_auth_account_component.gcp_agentless_scan.type}/${sysdig_secure_cloud_auth_account_component.gcp_agentless_scan.instance}"
  description = "Component identifier of Agentless Scan integration created in Sysdig Backend for VM"
  depends_on  = [sysdig_secure_cloud_auth_account_component.gcp_agentless_scan]
}

output "component_ready" {
  value       = time_sleep.wait_for_component_readiness
  description = "Wait handle to ensure component is fully registered before creating features"
}
