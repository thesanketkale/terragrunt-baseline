# --------------------------------------------------------------------------------------------------
# Azure One-Time Bootstrap Stack
# Creates the Storage Account remote state backend and initial Entra ID OIDC application using local state.
# --------------------------------------------------------------------------------------------------

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azuread" {}

module "state_backend" {
  source = "../../modules/azure/state-backend"

  resource_group_name  = "rg-tfstate-${var.location}-bootstrap"
  location             = var.location
  storage_account_name = "sttfstate${substr(replace(var.subscription_id, "-", ""), 0, 14)}"
  tags                 = var.tags
}

module "github_oidc" {
  source = "../../modules/azure/github-oidc"

  github_org         = var.github_org
  github_repo        = var.github_repo
  environment        = "dev"
  subscription_id    = var.subscription_id
  storage_account_id = module.state_backend.storage_account_id
}
