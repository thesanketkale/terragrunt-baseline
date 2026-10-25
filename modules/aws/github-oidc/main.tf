# GitHub Actions OIDC Identity Provider
resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = var.tags
}

data "aws_iam_openid_connect_provider" "existing" {
  count = var.create_oidc_provider ? 0 : 1
  url   = "https://token.actions.githubusercontent.com"
}

locals {
  oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.existing[0].arn
  repo_subject_base = "repo:${var.github_org}/${var.github_repo}"
}

# --------------------------------------------------------------------------------------------------
# Plan Role: Read-Only, Assumed by Pull Requests and Main Branch Planning
# --------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "plan_assume_role" {
  statement {
    sid     = "GitHubActionsPlanOIDC"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "${local.repo_subject_base}:pull_request",
        "${local.repo_subject_base}:ref:refs/heads/main"
      ]
    }
  }
}

resource "aws_iam_role" "plan" {
  name                 = "github-actions-plan-${var.environment}"
  description          = "Least-privilege read-only role assumed by GitHub Actions for terragrunt plan"
  assume_role_policy   = data.aws_iam_policy_document.plan_assume_role.json
  max_session_duration = 3600

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "plan_readonly" {
  role       = aws_iam_role.plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# --------------------------------------------------------------------------------------------------
# Apply Role: Environment-Scoped Mutation Permissions
# --------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "apply_assume_role" {
  statement {
    sid     = "GitHubActionsApplyOIDC"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "${local.repo_subject_base}:environment:${var.environment}"
      ]
    }
  }
}

resource "aws_iam_role" "apply" {
  name                 = "github-actions-apply-${var.environment}"
  description          = "Scoped deployment role assumed by GitHub Actions for terragrunt apply in ${var.environment}"
  assume_role_policy   = data.aws_iam_policy_document.apply_assume_role.json
  max_session_duration = 7200

  tags = var.tags
}

# Scoped deployment policy for apply role
data "aws_iam_policy_document" "apply_permissions" {
  statement {
    sid    = "TerraformStateAccess"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "NetworkAndInfraManagement"
    effect = "Allow"
    actions = [
      "ec2:*Vpc*",
      "ec2:*Subnet*",
      "ec2:*RouteTable*",
      "ec2:*InternetGateway*",
      "ec2:*NatGateway*",
      "ec2:*SecurityGroup*",
      "ec2:*VpcEndpoint*",
      "ec2:Describe*",
      "budgets:*",
      "sns:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "apply" {
  name        = "github-actions-deploy-policy-${var.environment}"
  description = "Scoped permissions policy for GitHub Actions deployments in ${var.environment}"
  policy      = data.aws_iam_policy_document.apply_permissions.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "apply" {
  role       = aws_iam_role.apply.name
  policy_arn = aws_iam_policy.apply.arn
}
