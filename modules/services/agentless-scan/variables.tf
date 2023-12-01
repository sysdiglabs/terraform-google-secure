variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "worker_identity" {
  type        = string
  description = "Sysdig provided Identity for the Service Account in charge of performing the host disk analysis"
}

variable "sysdig_backend" {
  type        = string
  description = "Sysdig provided AWS Account designated for the host scan"
  default     = null
}

variable "sysdig_account_id" {
  type        = string
  description = "Sysdig provided GCP Account designated for the host scan"
  default     = null
}



# optionals
variable "role_name" {
  type        = string
  description = "Name for the Worker Role on the Customer infrastructure"
  default     = "SysdigAgentlessHostRole"
}



variable "suffix" {
  type        = string
  description = "Suffix word to enable multiple deployments with different naming. Workload Identity Pool and Providers have a soft deletion on Google that will disallow name re-utilization"
  default     = null
}