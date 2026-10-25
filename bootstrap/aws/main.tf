# --------------------------------------------------------------------------------------------------
# AWS One-Time Bootstrap Stack
# Creates the S3 remote state bucket and initial GitHub OIDC federation roles using local state.
# --------------------------------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

module "state_backend" {
  source = "../../modules/aws/state-backend"

  bucket_name = "terragrunt-state-${var.account_id}-${var.aws_region}"
  tags        = var.tags
}

module "github_oidc" {
  source = "../../modules/aws/github-oidc"

  github_org           = var.github_org
  github_repo          = var.github_repo
  environment          = "dev"
  create_oidc_provider = true
  tags                 = var.tags
}
