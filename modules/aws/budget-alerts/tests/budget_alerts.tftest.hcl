# Native Terraform Test for AWS Budget Alerts Module
# Uses mock_provider to test monthly budget thresholds.

mock_provider "aws" {}

run "verify_budget_notifications" {
  command = plan

  variables {
    budget_name        = "monthly-budget-dev"
    limit_amount       = "100"
    limit_unit         = "USD"
    time_unit          = "MONTHLY"
    notification_email = "devops-alerts@example.com"
  }

  assert {
    condition     = aws_budgets_budget.cost.limit_amount == "100"
    error_message = "Budget limit amount must be 100."
  }

  assert {
    condition     = aws_budgets_budget.cost.budget_type == "COST"
    error_message = "Budget type must be COST."
  }

  assert {
    condition     = length(aws_budgets_budget.cost.notification) == 3
    error_message = "Must configure exactly 3 notification thresholds (50%, 80%, 100%)."
  }
}
