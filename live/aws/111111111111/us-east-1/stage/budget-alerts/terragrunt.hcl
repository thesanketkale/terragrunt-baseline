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
  env         = local.root_config.locals.env
}

inputs = {
  budget_name  = "monthly-budget-${local.env}"
  limit_amount = local.env_vars.locals.budget_limit
}
