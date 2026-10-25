output "oidc_provider_arn" {
  value       = local.oidc_provider_arn
  description = "The ARN of the GitHub Actions IAM OIDC provider."
}

output "plan_role_arn" {
  value       = aws_iam_role.plan.arn
  description = "The ARN of the read-only Plan role assumed by pull requests."
}

output "apply_role_arn" {
  value       = aws_iam_role.apply.arn
  description = "The ARN of the mutation Apply role assumed by environment deployments."
}
