variable "project_id" {
  type        = string
  description = "(Required) Target Project identifier provided by the customer"
}

variable "is_organizational" {
  description = "(Optional) Set this field to 'true' to deploy secure-for-cloud to a GCP Organization."
  type        = bool
  default     = false
}

variable "organization_domain" {
  type        = string
  description = "(Optional) Organization domain. e.g. sysdig.com"
  default     = ""
}

variable "management_group_ids" {
  type        = set(string)
  description = "(Optional) Management group id to onboard. e.g. [organizations/123456789012], [folders/123456789012]"
  default     = []
}

variable "suffix" {
  type        = string
  description = "Suffix to uniquely identify resources during multiple installs. If not provided, random value is autogenerated"
  default     = null
}