# Native Terraform Test for AWS GitHub OIDC Module
# Uses mock_provider for offline validation of IAM roles and trust policies.

mock_provider "aws" {}

run "verify_plan_and_apply_roles" {
  command = plan

  variables {
    github_org           = "thesanketkale"
    github_repo          = "terragrunt-live-template"
    environment          = "dev"
    create_oidc_provider = true
    tags = {
      Project     = "terragrunt-baseline"
      Environment = "dev"
    }
  }

  assert {
    condition     = length(aws_iam_openid_connect_provider.github) == 1
    error_message = "IAM OIDC provider must be created when create_oidc_provider is true."
  }

  assert {
    condition     = aws_iam_role.plan.name == "github-actions-plan-dev"
    error_message = "Plan role name must match environment naming convention."
  }

  assert {
    condition     = aws_iam_role.apply.name == "github-actions-apply-dev"
    error_message = "Apply role name must match environment naming convention."
  }

  assert {
    condition     = aws_iam_role.plan.max_session_duration == 3600
    error_message = "Plan role session duration should be 1 hour."
  }
}
