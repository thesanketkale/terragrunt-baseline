output "state_bucket_id" {
  value       = module.state_backend.bucket_id
  description = "The provisioned remote state S3 bucket."
}

output "oidc_provider_arn" {
  value       = module.github_oidc.oidc_provider_arn
  description = "The provisioned GitHub Actions IAM OIDC provider ARN."
}

output "plan_role_arn" {
  value       = module.github_oidc.plan_role_arn
  description = "The Plan role ARN to configure in GitHub repository secrets/variables."
}

output "apply_role_arn" {
  value       = module.github_oidc.apply_role_arn
  description = "The Apply role ARN to configure in GitHub repository secrets/variables."
}
