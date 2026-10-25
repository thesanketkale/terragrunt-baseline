# Azure Entra ID Application for GitHub Actions
resource "azuread_application" "github" {
  display_name = "github-actions-${var.github_repo}-${var.environment}"
  description  = "Entra ID application for GitHub Actions OIDC federation in ${var.environment}"
}

# Service Principal associated with Application
resource "azuread_service_principal" "github" {
  client_id = azuread_application.github.client_id
}

# --------------------------------------------------------------------------------------------------
# Federated Identity Credentials
# --------------------------------------------------------------------------------------------------

# Plan Credential (Pull Requests)
resource "azuread_application_federated_identity_credential" "plan_pr" {
  application_id = azuread_application.github.id
  display_name   = "github-actions-plan-pr"
  description    = "Federated credential for GitHub Actions pull requests (read-only plan)"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_org}/${var.github_repo}:pull_request"
}

# Plan Credential (Main Branch Plan)
resource "azuread_application_federated_identity_credential" "plan_main" {
  application_id = azuread_application.github.id
  display_name   = "github-actions-plan-main"
  description    = "Federated credential for GitHub Actions main branch plan"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
}

# Apply Credential (Environment-Scoped)
resource "azuread_application_federated_identity_credential" "apply" {
  application_id = azuread_application.github.id
  display_name   = "github-actions-apply-${var.environment}"
  description    = "Federated credential for GitHub Actions environment deployments in ${var.environment}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_org}/${var.github_repo}:environment:${var.environment}"
}

# --------------------------------------------------------------------------------------------------
# Role Assignments
# --------------------------------------------------------------------------------------------------
locals {
  scope = var.resource_group_id != null ? var.resource_group_id : "/subscriptions/${var.subscription_id}"
}

# Reader role for infrastructure inspection
resource "azurerm_role_assignment" "reader" {
  scope                = local.scope
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.github.object_id
}

# Contributor role for apply deployments
resource "azurerm_role_assignment" "contributor" {
  scope                = local.scope
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github.object_id
}

# Storage Blob Data Contributor on state account for state locking and write access
resource "azurerm_role_assignment" "storage_data" {
  count                = var.storage_account_id != null ? 1 : 0
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.github.object_id
}
