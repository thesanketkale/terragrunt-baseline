# Native Terraform Test for Azure GitHub OIDC Module
# Uses mock_provider to test Entra ID application and federated credentials.

mock_provider "azuread" {}
mock_provider "azurerm" {}

run "verify_federated_credentials" {
  command = plan

  variables {
    github_org      = "thesanketkale"
    github_repo     = "terragrunt-live-template"
    environment     = "dev"
    subscription_id = "00000000-0000-0000-0000-000000000000"
  }

  assert {
    condition     = azuread_application.github.display_name == "github-actions-terragrunt-live-template-dev"
    error_message = "Application display name does not match expected convention."
  }

  assert {
    condition     = azuread_application_federated_identity_credential.plan_pr.subject == "repo:thesanketkale/terragrunt-live-template:pull_request"
    error_message = "Plan PR subject claim must target pull_request."
  }

  assert {
    condition     = azuread_application_federated_identity_credential.apply.subject == "repo:thesanketkale/terragrunt-live-template:environment:dev"
    error_message = "Apply subject claim must target the specific environment."
  }
}
