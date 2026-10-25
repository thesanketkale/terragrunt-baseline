variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "The vpc_cidr value must be a valid CIDR notation (e.g. 10.0.0.0/16)."
  }
}

variable "azs" {
  type        = list(string)
  description = "List of Availability Zones to deploy subnets across (2 to 3 AZs)."
  default     = ["us-east-1a", "us-east-1b"]
  validation {
    condition     = length(var.azs) >= 2 && length(var.azs) <= 3
    error_message = "You must provide between 2 and 3 Availability Zones."
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets (matching the number of AZs)."
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for application private subnets (matching the number of AZs)."
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "data_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for isolated data/database subnets (matching the number of AZs)."
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Whether to provision NAT Gateways for private subnet internet egress."
  default     = true
}

variable "single_nat_gateway" {
  type        = bool
  description = "If true, provision a single shared NAT Gateway across all AZs to minimize non-prod costs."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Resource tags applied to all network resources."
  default     = {}
}
