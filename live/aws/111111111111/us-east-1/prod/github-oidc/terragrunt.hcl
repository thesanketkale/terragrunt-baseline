include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/github-oidc.hcl"
  expose = true
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  env         = local.root_config.locals.env
}

inputs = {
  environment          = local.env
  create_oidc_provider = false
}
