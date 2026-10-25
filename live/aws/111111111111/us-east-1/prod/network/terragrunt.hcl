include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/network.hcl"
  expose = true
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  env         = local.root_config.locals.env
}

inputs = {
  vpc_cidr           = "10.20.0.0/16"
  single_nat_gateway = false # High availability: 1 NAT Gateway per AZ in production
}
