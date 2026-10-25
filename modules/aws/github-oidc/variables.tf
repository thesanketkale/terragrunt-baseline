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

variable "create_oidc_provider" {
  type        = bool
  description = "Whether to create the GitHub OIDC provider in this AWS account. Set to false if already provisioned."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Resource tags applied to all provisioned resources."
  default     = {}
}
