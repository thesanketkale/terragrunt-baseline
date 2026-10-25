variable "subscription_id" {
  type        = string
  description = "Target Azure subscription ID."
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "location" {
  type        = string
  description = "Azure region for bootstrap resources."
  default     = "eastus"
}

variable "github_org" {
  type        = string
  description = "GitHub organization or user."
  default     = "thesanketkale"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name."
  default     = "terragrunt-live-template"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all bootstrap resources."
  default = {
    Project   = "terragrunt-baseline"
    ManagedBy = "bootstrap"
  }
}
