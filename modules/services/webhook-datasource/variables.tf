variable "project_id" {
  type        = string
  description = "(Required) Target Project identifier provided by the customer"
}

variable "push_endpoint" {
  type        = string
  description = "(Required) Final endpoint towards which audit logs POST calls will be directed"
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
