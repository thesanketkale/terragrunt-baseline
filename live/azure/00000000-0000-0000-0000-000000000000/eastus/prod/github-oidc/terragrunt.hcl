include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/github-oidc.hcl"
  expose = true
}

locals {
  root_config     = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  subscription_id = local.root_config.locals.subscription_id
  env             = local.root_config.locals.env
}

dependency "state_backend" {
  config_path = "../state-backend"
  mock_outputs = {
    storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-mock/providers/Microsoft.Storage/storageAccounts/stmock"
  }
}

inputs = {
  environment        = local.env
  subscription_id    = local.subscription_id
  storage_account_id = dependency.state_backend.outputs.storage_account_id
}
