# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION FOR NETWORK STACK
# This configuration is included by child terragrunt.hcl files.
# ---------------------------------------------------------------------------------------------------------------------

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  cloud       = local.root_config.locals.is_aws ? "aws" : "azure"
  base_source = "${get_repo_root()}/modules/${local.cloud}/network"
}

terraform {
  source = local.base_source
}

inputs = {
  # Common VPC / VNet defaults
  cidr_block = "10.0.0.0/16"
}
