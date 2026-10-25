variable "resource_group_name" {
  type        = string
  description = "Name of the Azure Resource Group for networking resources."
}

variable "location" {
  type        = string
  description = "Azure region for the virtual network."
  default     = "eastus"
}

variable "vnet_name" {
  type        = string
  description = "Name of the Azure Virtual Network."
  default     = "vnet-main"
}

variable "address_space" {
  type        = list(string)
  description = "CIDR blocks for the Virtual Network address space."
  default     = ["10.0.0.0/16"]
}

variable "public_subnet_prefix" {
  type        = string
  description = "Address prefix for the public/frontend subnet."
  default     = "10.0.1.0/24"
}

variable "private_subnet_prefix" {
  type        = string
  description = "Address prefix for the application private subnet."
  default     = "10.0.11.0/24"
}

variable "data_subnet_prefix" {
  type        = string
  description = "Address prefix for the isolated database/data subnet."
  default     = "10.0.21.0/24"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Whether to provision an Azure NAT Gateway for secure outbound internet egress."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Resource tags applied to all networking resources."
  default     = {}
}
