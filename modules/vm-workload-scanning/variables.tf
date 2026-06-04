variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "is_organizational" {
  type        = bool
  description = "Set this field to 'true' to deploy workload scanning to a GCP Organization."
  default     = false
}

variable "organization_domain" {
  type        = string
  description = "(Optional) Organization domain. e.g. sysdig.com"
  default     = false
}

# optionals
variable "role_name" {
  type        = string
  description = "Name for the Worker Role on the Customer infrastructure"
  default     = "SysdigAgentlessWorkloadRole"
}

variable "sysdig_secure_account_id" {
  type        = string
  description = "ID of the Sysdig Cloud Account to enable Config Posture for (in case of organization, ID of the Sysdig management account)"
}

variable "wait_for_component_seconds" {
  type        = number
  description = "(Optional) Delay in seconds to wait after component operations (create/destroy) to ensure Sysdig backend has fully processed changes before proceeding. Set to 0 to disable."
  default     = 30
}
