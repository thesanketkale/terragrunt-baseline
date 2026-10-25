variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where the action group and budget are managed."
}

variable "budget_name" {
  type        = string
  description = "Name of the Azure Consumption Budget."
  default     = "monthly-cost-budget"
}

variable "amount" {
  type        = number
  description = "Total monthly budget amount."
  default     = 100
  validation {
    condition     = var.amount > 0
    error_message = "Budget amount must be strictly positive."
  }
}

variable "time_grain" {
  type        = string
  description = "Time grain for budget reset (Monthly, Quarterly, Annually)."
  default     = "Monthly"
}

variable "notification_email" {
  type        = string
  description = "Primary email address for budget alert notifications."
  default     = "devops-alerts@example.com"
  validation {
    condition     = can(regex("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", var.notification_email))
    error_message = "The notification_email must be a valid email format."
  }
}

variable "tags" {
  type        = map(string)
  description = "Resource tags applied to budget alert resources."
  default     = {}
}
