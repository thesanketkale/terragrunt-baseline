# Root Terragrunt Configuration
# Defines multi-cloud remote state, provider generation, and common hierarchical inputs.

locals {
  # Locate account-level or subscription-level configurations to determine cloud provider
  account_file      = find_in_parent_folders("account.hcl", "empty.hcl")
  subscription_file = find_in_parent_folders("subscription.hcl", "empty.hcl")
  is_aws            = local.account_file != "empty.hcl"
  is_azure          = local.subscription_file != "empty.hcl"

  # Safely load cloud-specific parent configurations
  account_vars      = local.is_aws ? read_terragrunt_config(local.account_file) : { locals = {} }
  subscription_vars = local.is_azure ? read_terragrunt_config(local.subscription_file) : { locals = {} }

  # Load region and environment configurations
  region_file = find_in_parent_folders("region.hcl", "empty.hcl")
  env_file    = find_in_parent_folders("env.hcl", "empty.hcl")

  region_vars = local.region_file != "empty.hcl" ? read_terragrunt_config(local.region_file) : { locals = {} }
  env_vars    = local.env_file != "empty.hcl" ? read_terragrunt_config(local.env_file) : { locals = {} }

  # Normalized identifiers
  account_id      = try(local.account_vars.locals.account_id, "111111111111")
  subscription_id = try(local.subscription_vars.locals.subscription_id, "00000000-0000-0000-0000-000000000000")
  aws_region      = try(local.region_vars.locals.aws_region, "us-east-1")
  location        = try(local.region_vars.locals.location, "eastus")
  env             = try(local.env_vars.locals.env, "dev")

  # Standard baseline resource tags
  common_tags = {
    Project     = "terragrunt-baseline"
    Repository  = "thesanketkale/terragrunt-live-template"
    ManagedBy   = "terragrunt"
    Environment = local.env
  }

  aws_provider_content = <<EOF
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
  }
}

provider "aws" {
  region = "${local.aws_region}"
  default_tags {
    tags = {
      Project     = "terragrunt-baseline"
      Repository  = "thesanketkale/terragrunt-live-template"
      Environment = "${local.env}"
      ManagedBy   = "terragrunt"
    }
  }
}
EOF

  azure_provider_content = <<EOF
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.10"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "${local.subscription_id}"
}
EOF
}

# Dynamic Remote State Backend Generation
remote_state {
  backend = local.is_aws ? "s3" : "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = local.is_aws ? {
    encrypt      = true
    bucket       = "terragrunt-state-${local.account_id}-${local.aws_region}"
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = local.aws_region
    use_lockfile = true
    } : {
    resource_group_name  = "rg-tfstate-${local.location}-${local.env}"
    storage_account_name = "sttfstate${local.env}${substr(replace(local.subscription_id, "-", ""), 0, 8)}"
    container_name       = "tfstate"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
    use_azuread_auth     = true
  }
}

# Dynamic Provider Generation
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = local.is_aws ? local.aws_provider_content : local.azure_provider_content
}

# Global Inputs propagated to child modules
inputs = merge(
  local.account_vars.locals,
  local.subscription_vars.locals,
  local.region_vars.locals,
  local.env_vars.locals,
  {
    tags = local.common_tags
  }
)
