output "resource_group_name" {
  value       = module.state_backend.resource_group_name
  description = "The bootstrap state resource group name."
}

output "storage_account_name" {
  value       = module.state_backend.storage_account_name
  description = "The bootstrap state storage account name."
}

output "client_id" {
  value       = module.github_oidc.client_id
  description = "The Entra ID Client ID (App ID) to configure in GitHub repository secrets/variables."
}
