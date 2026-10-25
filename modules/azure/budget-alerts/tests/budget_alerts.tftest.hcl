# Native Terraform Test for Azure Budget Alerts Module
# Uses mock_provider to test Action Group and resource group consumption budget.

mock_provider "azurerm" {
  mock_data "azurerm_resource_group" {
    defaults = {
      id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-eastus-dev"
      location = "eastus"
    }
  }
}

run "verify_action_group_and_thresholds" {
  command = plan

  variables {
    resource_group_name = "rg-network-eastus-dev"
    budget_name         = "monthly-budget-dev"
    amount              = 100
    time_grain          = "Monthly"
    notification_email  = "devops-alerts@example.com"
  }

  assert {
    condition     = azurerm_monitor_action_group.budget.short_name == "budget-alert"
    error_message = "Action group short name must be budget-alert."
  }

  assert {
    condition     = azurerm_consumption_budget_resource_group.budget.amount == 100
    error_message = "Budget amount must match configured input."
  }

  assert {
    condition     = length(azurerm_consumption_budget_resource_group.budget.notification) == 3
    error_message = "Must configure exactly 3 notification thresholds."
  }
}
