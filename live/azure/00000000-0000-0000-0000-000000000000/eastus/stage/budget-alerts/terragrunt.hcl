include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/budget-alerts.hcl"
  expose = true
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  location    = local.root_config.locals.location
  env         = local.root_config.locals.env
}

dependency "network" {
  config_path = "../network"
  mock_outputs = {
    resource_group_name = "rg-network-eastus-stage"
  }
}

inputs = {
  resource_group_name = dependency.network.outputs.resource_group_name
  budget_name         = "monthly-budget-${local.env}"
  amount              = local.env_vars.locals.budget_limit
}
