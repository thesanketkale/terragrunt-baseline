output "budget_id" {
  value       = aws_budgets_budget.cost.id
  description = "The ID of the AWS Budget."
}

output "budget_name" {
  value       = aws_budgets_budget.cost.name
  description = "The name of the AWS Budget."
}
