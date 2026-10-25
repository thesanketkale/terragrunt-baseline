data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_monitor_action_group" "budget" {
  name                = "ag-budget-alerts"
  resource_group_name = data.azurerm_resource_group.rg.name
  short_name          = "budget-alert"

  email_receiver {
    name                    = "PrimaryDevOpsAlert"
    email_address           = var.notification_email
    use_common_alert_schema = true
  }

  tags = var.tags
}

resource "azurerm_consumption_budget_resource_group" "budget" {
  name              = var.budget_name
  resource_group_id = data.azurerm_resource_group.rg.id
  amount            = var.amount
  time_grain        = var.time_grain

  time_period {
    start_date = "2026-01-01T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = 50
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_groups = [azurerm_monitor_action_group.budget.id]
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_groups = [azurerm_monitor_action_group.budget.id]
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    contact_groups = [azurerm_monitor_action_group.budget.id]
  }
}
