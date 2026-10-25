output "action_group_id" {
  value       = azurerm_monitor_action_group.budget.id
  description = "The ID of the Azure Monitor Action Group."
}

output "budget_id" {
  value       = azurerm_consumption_budget_resource_group.budget.id
  description = "The ID of the Azure Consumption Budget."
}
