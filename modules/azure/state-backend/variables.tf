variable "resource_group_name" {
  type        = string
  description = "Name of the Azure Resource Group for remote state storage."
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_()]+$", var.resource_group_name))
    error_message = "Resource group name must contain only alphanumerics, hyphens, underscores, or parentheses."
  }
}

variable "location" {
  type        = string
  description = "Azure region where the storage account and resource group will be created."
  default     = "eastus"
}

variable "storage_account_name" {
  type        = string
  description = "Globally unique name for the Azure Storage Account (3-24 lowercase alphanumerics)."
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 lowercase letters and numbers."
  }
}

variable "container_name" {
  type        = string
  description = "Name of the blob storage container for Terraform state."
  default     = "tfstate"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags applied to state backend resources."
  default     = {}
}
