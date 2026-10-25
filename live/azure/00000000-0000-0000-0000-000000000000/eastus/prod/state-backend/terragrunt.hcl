include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/state-backend.hcl"
  expose = true
}

locals {
  root_config     = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  subscription_id = local.root_config.locals.subscription_id
  location        = local.root_config.locals.location
  env             = local.root_config.locals.env
}

inputs = {
  resource_group_name  = "rg-tfstate-${local.location}-${local.env}"
  storage_account_name = "sttfstate${local.env}${substr(replace(local.subscription_id, "-", ""), 0, 8)}"
  location             = local.location
}
