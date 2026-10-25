#!/usr/bin/env bash
# --------------------------------------------------------------------------------------------------
# Azure One-Time Bootstrap Script
# Idempotently provisions initial Storage Account state backend and Entra ID application with local state.
# --------------------------------------------------------------------------------------------------
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP_DIR="$REPO_ROOT/bootstrap/azure"

echo "==> [Azure Bootstrap] Initializing local Terraform state in $BOOTSTRAP_DIR..."
cd "$BOOTSTRAP_DIR"

terraform init -input=false

echo "==> [Azure Bootstrap] Running plan for Storage Account state backend and Entra ID OIDC..."
terraform plan -out=bootstrap.tfplan -input=false

echo "==> [Azure Bootstrap] Note: Execute 'terraform apply bootstrap.tfplan' to create resources."
echo "==> After creation, configure GitHub Actions variables with Client ID, Tenant ID, and Subscription ID."
