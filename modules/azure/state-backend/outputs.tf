output "resource_group_name" {
  value       = azurerm_resource_group.state.name
  description = "The name of the state backend resource group."
}

output "storage_account_id" {
  value       = azurerm_storage_account.state.id
  description = "The ID of the Azure Storage Account."
}

output "storage_account_name" {
  value       = azurerm_storage_account.state.name
  description = "The name of the Azure Storage Account."
}

output "container_name" {
  value       = azurerm_storage_container.state.name
  description = "The name of the state blob container."
}
