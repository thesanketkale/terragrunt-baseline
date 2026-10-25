# Owner Verification Log & Handoff Runbook

This document provides exact, copy-paste terminal commands and expected outputs for repository owners to verify live cloud operations (AWS & Azure OIDC authentication, bootstrap, speculative plan, and apply) in under 10 minutes.

---

## Verification Summary Table

| Check ID | Verification Item | Proof Method | Status | Required Credentials |
| :--- | :--- | :--- | :--- | :--- |
| `AC-CI-01` | HCL & Terraform Formatting | Automated in CI | :white_check_mark: Green | None |
| `AC-CI-02` | Module Validation | Automated in CI | :white_check_mark: Green | None |
| `AC-CI-03` | TFLint Static Analysis | Automated in CI | :white_check_mark: Green | None |
| `AC-CI-04` | Native Mock Tests (`mock_provider`) | Automated in CI | :white_check_mark: Green | None |
| `AC-CI-05` | Terragrunt Hierarchy & Mock Outputs | Automated in CI | :white_check_mark: Green | None |
| `AC-CI-06` | Least-Privilege GitHub Actions Workflows | Automated in CI | :white_check_mark: Green | None |
| `AC-CI-07` | Clean-Room & Security Guard | Automated in CI | :white_check_mark: Green | None |
| `AC-OWNER-01` | Live AWS Bootstrap & OIDC Plan | Owner Terminal | ⏳ Pending Owner | AWS Sandbox Credentials |
| `AC-OWNER-02` | Live Azure Bootstrap & OIDC Plan | Owner Terminal | ⏳ Pending Owner | Azure Sandbox Subscription |
| `AC-OWNER-03` | Live GitHub Actions Plan & Apply PR | GitHub Web UI | ⏳ Pending Owner | GitHub Repo Admin Access |
| `AC-OWNER-04` | Nightly Drift Detection Workflow | GitHub Actions | ⏳ Pending Owner | GitHub Repo Admin Access |

---

## 1. Owner-Verification Procedure: AWS Bootstrap & OIDC (`AC-OWNER-01`)

### Step 1: Set AWS Sandbox Environment Variables
```bash
export AWS_REGION="us-east-1"
export AWS_PROFILE="my-sandbox-profile" # Or export AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
```

### Step 2: Run Bootstrap Script
```bash
./scripts/bootstrap-aws.sh
```

**Expected Output:**
```text
==> [AWS Bootstrap] Initializing local Terraform state in .../bootstrap/aws...
Terraform has been successfully initialized!
==> [AWS Bootstrap] Running plan for S3 state backend and GitHub Actions OIDC...
Plan: 6 to add, 0 to change, 0 to destroy.
Changes to Outputs:
  + apply_role_arn    = "arn:aws:iam::...:role/github-actions-apply-dev"
  + oidc_provider_arn = "arn:aws:iam::...:oidc-provider/token.actions.githubusercontent.com"
  + plan_role_arn     = "arn:aws:iam::...:role/github-actions-plan-dev"
  + state_bucket_id   = "terragrunt-state-..."
```

### Step 3: Apply Bootstrap Plan
```bash
cd bootstrap/aws
terraform apply bootstrap.tfplan
```

### Step 4: Verify Terragrunt Plan with Created Role
```bash
cd ../../live/aws/111111111111/us-east-1/dev/network
terragrunt plan
```

---

## 2. Owner-Verification Procedure: Azure Bootstrap & OIDC (`AC-OWNER-02`)

### Step 1: Authenticate to Azure CLI
```bash
az login
az account set --subscription "<YOUR_SANDBOX_SUBSCRIPTION_ID>"
```

### Step 2: Run Bootstrap Script
```bash
./scripts/bootstrap-azure.sh
```

**Expected Output:**
```text
==> [Azure Bootstrap] Initializing local Terraform state in .../bootstrap/azure...
Terraform has been successfully initialized!
==> [Azure Bootstrap] Running plan for Storage Account state backend and Entra ID OIDC...
Plan: 6 to add, 0 to change, 0 to destroy.
Changes to Outputs:
  + client_id            = "..."
  + resource_group_name  = "rg-tfstate-eastus-bootstrap"
  + storage_account_name = "sttfstate..."
```

### Step 3: Apply Bootstrap Plan
```bash
cd bootstrap/azure
terraform apply bootstrap.tfplan
```

---

## 3. Owner-Verification Procedure: Live PR & GitHub Actions (`AC-OWNER-03`)

1. In GitHub Repository Settings, add the following Repository Secrets:
   - `AWS_PLAN_ROLE_ARN`: Output from AWS bootstrap
   - `AWS_APPLY_ROLE_ARN`: Output from AWS bootstrap
   - `AZURE_CLIENT_ID`: Output from Azure bootstrap
   - `AZURE_TENANT_ID`: Azure Directory (Tenant) ID
   - `AZURE_SUBSCRIPTION_ID`: Azure Subscription ID
2. Create a test branch and push a minor comment change to `live/aws/111111111111/us-east-1/dev/network/terragrunt.hcl`.
3. Open a Pull Request.
4. Verify that `plan.yml` triggers, runs without errors, and posts a sticky comment summarizing the plan.
5. Merge the Pull Request into `main` and verify that `apply.yml` executes successfully.
