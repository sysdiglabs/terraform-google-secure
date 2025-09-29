variable "project_id" {
  type        = string
  description = "The ID of the target Google cloud project to create resources in."
}

variable "service_account_name" {
  type        = string
  description = "The name of the Service Account that will be created."
  default     = "sysdig-secure"
}

variable "is_organizational" {
  description = "(Optional) Set this field to 'true' to deploy secure-for-cloud to a GCP Organization."
  type        = bool
  default     = false
}

variable "organization_domain" {
  type        = string
  description = "Organization domain. e.g. sysdig.com"
  default     = ""
}
