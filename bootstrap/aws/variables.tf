variable "aws_region" {
  type        = string
  description = "Target AWS region."
  default     = "us-east-1"
}

variable "account_id" {
  type        = string
  description = "Target AWS account ID (12 digits)."
  default     = "111111111111"
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
