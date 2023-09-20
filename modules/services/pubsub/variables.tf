variable "project_id" {
  type        = string
  description = "(Required) Target Project identifier provided by the customer"
}

variable "push_endpoint" {
  type        = string
  description = "(Required) Final endpoint towards which audit logs POST calls will be directed"
}
