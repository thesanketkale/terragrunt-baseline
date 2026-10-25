#!/usr/bin/env bash
# Verification Script for terragrunt-live-template (Bash)
set -euo pipefail

MODE="${1:-fast}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "==> Verification mode: $MODE"

# 1. Clean-Room Guard
echo "==> Running clean-room guard..."
"$REPO_ROOT/tools/guard.sh"

# 2. Terraform Format Check
echo "==> Checking Terraform formatting..."
if find . -name '*.tf' -not -path '*/.terraform/*' -not -path '*/.terragrunt-cache/*' | read -r; then
  terraform fmt -check -recursive
fi

# 3. Terragrunt HCL Format Check
echo "==> Checking Terragrunt HCL formatting..."
if find . -name '*.hcl' -not -path '*/.terraform/*' -not -path '*/.terragrunt-cache/*' | read -r; then
  terragrunt hcl fmt --check 2>/dev/null || terragrunt hclfmt --terragrunt-check
fi

# 4. GitHub Actions Workflow Syntax Check
if [ -d ".github/workflows" ]; then
  echo "==> Checking workflow YAML syntax..."
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "import glob, yaml, sys; [yaml.safe_load(open(f, encoding='utf-8')) for f in glob.glob('.github/workflows/*.y*ml')]"
  elif command -v python >/dev/null 2>&1; then
    python -c "import glob, yaml, sys; [yaml.safe_load(open(f, encoding='utf-8')) for f in glob.glob('.github/workflows/*.y*ml')]"
  fi
fi

if [ "$MODE" = "full" ]; then
  echo "==> Validating all Terraform modules..."
  find modules bootstrap -name "main.tf" -exec dirname {} \; | sort -u | while read -r dir; do
    echo "  Validating: $dir"
    (cd "$dir" && terraform init -backend=false -input=false >/dev/null 2>&1 && terraform validate -no-color)
  done

  if command -v tflint >/dev/null 2>&1; then
    echo "==> Running TFLint..."
    tflint --recursive
  fi

  echo "==> Running native terraform tests..."
  find modules -name "tests" -type d | while read -r testdir; do
    moddir="$(dirname "$testdir")"
    echo "  Testing: $moddir"
    (cd "$moddir" && terraform test -no-color)
  done
fi

echo "[+] Verification ($MODE) COMPLETED SUCCESSFULLY!"
