include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/state-backend.hcl"
  expose = true
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  account_id  = local.root_config.locals.account_id
  aws_region  = local.root_config.locals.aws_region
}

inputs = {
  bucket_name = "terragrunt-state-${local.account_id}-${local.aws_region}"
}
