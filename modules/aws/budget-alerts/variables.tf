variable "budget_name" {
  type        = string
  description = "Name of the AWS Budget."
  default     = "monthly-cost-budget"
}

variable "limit_amount" {
  type        = string
  description = "The monthly budget limit amount."
  default     = "100"
  validation {
    condition     = can(regex("^[0-9]+(\\.[0-9]{1,2})?$", var.limit_amount))
    error_message = "Limit amount must be a numeric string (e.g. '100' or '150.50')."
  }
}

variable "limit_unit" {
  type        = string
  description = "Currency unit for the budget."
  default     = "USD"
}

variable "time_unit" {
  type        = string
  description = "The time unit for the budget cycle (MONTHLY, QUARTERLY, ANNUALLY)."
  default     = "MONTHLY"
  validation {
    condition     = contains(["MONTHLY", "QUARTERLY", "ANNUALLY"], var.time_unit)
    error_message = "time_unit must be MONTHLY, QUARTERLY, or ANNUALLY."
  }
}

variable "notification_email" {
  type        = string
  description = "Primary email address to receive budget alert notifications."
  default     = "devops-alerts@example.com"
  validation {
    condition     = can(regex("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", var.notification_email))
    error_message = "The notification_email must be a valid email format."
  }
}

variable "sns_topic_arn" {
  type        = string
  description = "Optional SNS Topic ARN to publish budget alerts to."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Resource tags applied to budget alert resources."
  default     = {}
}
