# --------------------------------------------------------------------------------------------------
# AWS Monthly Cost Budget with Multi-Threshold Notifications
# --------------------------------------------------------------------------------------------------
resource "aws_budgets_budget" "cost" {
  name         = var.budget_name
  budget_type  = "COST"
  limit_amount = var.limit_amount
  limit_unit   = var.limit_unit
  time_unit    = var.time_unit

  # 50% Actual Spend Alert
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.notification_email]
    subscriber_sns_topic_arns  = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
  }

  # 80% Actual Spend Alert
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.notification_email]
    subscriber_sns_topic_arns  = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
  }

  # 100% Forecasted Spend Alert
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.notification_email]
    subscriber_sns_topic_arns  = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
  }

  tags = var.tags
}
