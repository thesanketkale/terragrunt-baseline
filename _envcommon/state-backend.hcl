# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION FOR STATE-BACKEND STACK
# This configuration is included by child terragrunt.hcl files.
# ---------------------------------------------------------------------------------------------------------------------

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  cloud       = local.root_config.locals.is_aws ? "aws" : "azure"
  base_source = "${get_repo_root()}/modules/${local.cloud}/state-backend"
}

terraform {
  source = local.base_source
}

inputs = {
  # State backend baseline variables
  prevent_destroy = true
}
