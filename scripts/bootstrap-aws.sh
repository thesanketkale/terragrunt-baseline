#!/usr/bin/env bash
# --------------------------------------------------------------------------------------------------
# AWS One-Time Bootstrap Script
# Idempotently provisions initial S3 state bucket and GitHub Actions IAM OIDC provider with local state.
# --------------------------------------------------------------------------------------------------
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP_DIR="$REPO_ROOT/bootstrap/aws"

echo "==> [AWS Bootstrap] Initializing local Terraform state in $BOOTSTRAP_DIR..."
cd "$BOOTSTRAP_DIR"

terraform init -input=false

echo "==> [AWS Bootstrap] Running plan for S3 state backend and GitHub Actions OIDC..."
terraform plan -out=bootstrap.tfplan -input=false

echo "==> [AWS Bootstrap] Note: Execute 'terraform apply bootstrap.tfplan' to create resources."
echo "==> After creation, configure GitHub Actions variables with the role ARNs printed by outputs."
