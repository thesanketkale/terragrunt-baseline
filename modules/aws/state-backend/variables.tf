variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket for Terragrunt state storage."
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "The bucket name must be a valid S3 bucket name (lowercase letters, numbers, hyphens, and periods)."
  }
}

variable "kms_key_arn" {
  type        = string
  description = "Optional KMS Key ARN for S3 server-side encryption. If not provided, AES256 is used."
  default     = null
}

variable "create_dynamodb_lock_table" {
  type        = bool
  description = "Whether to create a DynamoDB table for distributed state locking (legacy fallback for Terraform < 1.10)."
  default     = false
}

variable "dynamodb_table_name" {
  type        = string
  description = "Name of the DynamoDB table if create_dynamodb_lock_table is enabled."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Resource tags applied to all provisioned resources."
  default     = {}
}
