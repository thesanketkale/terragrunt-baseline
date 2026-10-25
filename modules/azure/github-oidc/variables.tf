variable "github_org" {
  type        = string
  description = "The GitHub organization or username owning the repository."
  default     = "thesanketkale"
  validation {
    condition     = length(var.github_org) > 0
    error_message = "The github_org must not be empty."
  }
}

variable "github_repo" {
  type        = string
  description = "The GitHub repository name."
  default     = "terragrunt-live-template"
  validation {
    condition     = length(var.github_repo) > 0
    error_message = "The github_repo must not be empty."
  }
}

variable "environment" {
  type        = string
  description = "Target deployment environment tier (dev, stage, prod)."
  default     = "dev"
  validation {
    condition     = contains(["dev", "stage", "prod", "shared"], var.environment)
    error_message = "Environment must be one of: dev, stage, prod, shared."
  }
}

variable "subscription_id" {
  type        = string
  description = "Target Azure Subscription ID for role assignments."
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "resource_group_id" {
  type        = string
  description = "Optional Azure Resource Group ID to scope Contributor permissions strictly to that RG."
  default     = null
}

variable "storage_account_id" {
  type        = string
  description = "Optional Storage Account ID for state storage role assignments."
  default     = null
}
