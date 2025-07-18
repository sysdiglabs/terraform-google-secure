variable "project_id" {
  type        = string
  description = "(Required) Target Project identifier provided by the customer"
}

variable "labels" {
  type        = map(string)
  description = "(Optional) Labels to be associated with Sysdig-originated resources"
  default = {
    originator = "sysdig"
  }
}

variable "ack_deadline_seconds" {
  type        = number
  description = "(Optional) Maximum time in seconds after Sysdig's subscriber receives a message before the subscriber should acknowledge the message"
  default     = 60
}

variable "message_retention_duration" {
  type        = string
  description = "(Optional) How long unacknowledged messages are retained in Sysdig's subscription backlog, from the moment a message is published"
  default     = "604800s"
}

variable "max_delivery_attempts" {
  type        = number
  description = "(Optional) Number of attempts redelivering missed messages from the deadletter topic to the main one"
  default     = 5
}

variable "minimum_backoff" {
  type        = string
  description = "(Optional) Minimum backoff time for exponential backoff of the push subscription retry policy"
  default     = "10s"
}

variable "maximum_backoff" {
  type        = string
  description = "(Optional) Maximum backoff time for exponential backoff of the push subscription retry policy"
  default     = "600s"
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

variable "suffix" {
  type        = string
  description = "Suffix to uniquely identify resources during multiple installs. If not provided, random value is autogenerated"
  default     = null
}

variable "audit_log_config" {
  description = "List of services and their audit log configurations to be ingested. Default is to ingest all logs."
  type = list(object({
    service = string,
    log_config = list(object({
      log_type         = string,
      exempted_members = optional(list(string))
    }))
  }))
  default = [
    {
      service = "allServices"
      log_config = [
        { log_type = "ADMIN_READ" },
        { log_type = "DATA_READ" },
        { log_type = "DATA_WRITE" }
      ]
    }
  ]
}

variable "exclude_logs_filter" {
  description = "Filter to exclude logs from ingestion. Default is to ingest all google.cloud.audit.AuditLog logs. with no exclusions."
  type = list(object({
    name        = string,
    description = optional(string),
    filter      = string,
    disabled    = optional(bool)
  }))
  default = [
    {
      name        = "system_principals"
      description = "Exclude system principals"
      filter      = "protoPayload.authenticationInfo.principalEmail=~\"^system\\:.*\" AND (protoPayload.authenticationInfo.principalEmail!~\"^system\\:(anonymous|serviceaccount)*\" OR protoPayload.authenticationInfo.principalEmail=~\"^system\\:serviceaccount\\:kube-system\")"
    },
    {
      name        = "k8s_audit"
      description = "Exclude logs from the clusters control planes"
      filter      = "protoPayload.methodName=~\"^(io\\.k8s|io\\.traefik|us\\.containo|io\\.x-k8s|io\\.gke|org\\.projectcalico|io\\.openshift|io\\.istio)\" AND protoPayload.methodName!~\"secret\""
    },
    {
      name        = "ciulium_control_plane"
      description = "Exclude operations on Cilium"
      filter      = "protoPayload.methodName=~\"^io\\.cilium\" AND protoPayload.methodName!~\"identitites\""
    },
    {
      name        = "monitoring_queries"
      description = "Exclude monitoring queries"
      filter      = "protoPayload.methodName=~\"^com\\.coreos\""
    }
  ]
}

variable "ingestion_sink_filter" {
  type        = string
  description = "Filter the Logging Sink is set up with. Default is to ingests AuditLogs"
  default     = "protoPayload.@type = \"type.googleapis.com/google.cloud.audit.AuditLog\""
}

variable "sysdig_secure_account_id" {
  type        = string
  description = "ID of the Sysdig Cloud Account to enable to enable Pub Sub integration for (incase of organization, ID of the Sysdig management account)"
}
