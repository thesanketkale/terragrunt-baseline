include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/network.hcl"
  expose = true
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  location    = local.root_config.locals.location
  env         = local.root_config.locals.env
}

inputs = {
  resource_group_name   = "rg-network-${local.location}-${local.env}"
  vnet_name             = "vnet-${local.env}"
  location              = local.location
  address_space         = ["10.20.0.0/16"]
  public_subnet_prefix  = "10.20.1.0/24"
  private_subnet_prefix = "10.20.11.0/24"
  data_subnet_prefix    = "10.20.21.0/24"
  enable_nat_gateway    = true
}
