# Getting Started with terragrunt-live-template

This guide walks you through setting up developer workstations, provisioning bootstrap state and identity resources, and deploying your first live infrastructure stack across AWS and Azure.

---

## 1. Prerequisites

Ensure your workstation or CI runner has the required tools installed. Versions are pinned in `.tool-versions`:

| Tool | Minimum Version | Installation Command (mise / asdf / choco / brew) |
| :--- | :--- | :--- |
| **Terraform** / **OpenTofu** | >= 1.6.0 (rec. 1.10.5) | `mise use terraform@1.10.5` or `brew install terraform` |
| **Terragrunt** | >= 0.63.0 | `mise use terragrunt@0.63.6` or `brew install terragrunt` |
| **TFLint** | >= 0.55.0 | `mise use tflint@0.55.0` or `brew install tflint` |
| **AWS CLI** / **Azure CLI** | Current | `aws --version` / `az version` |

---

## 2. Repository Layout Orientation

The repository separates reusable module logic from live state environments:
- `modules/`: Pure, testable Terraform modules (`aws` and `azure`).
- `live/`: Environment deployment units (`dev`, `stage`, `prod`).
- `root.hcl`: Centralized provider and remote backend generation.
- `_envcommon/`: Shared stack inputs.

---

## 3. One-Time Bootstrap (per Cloud Account)

Before automated CI/CD can run without credentials, run the bootstrap stack once using administrative credentials.

### AWS Bootstrap
1. Export administrative AWS credentials:
   ```bash
   export AWS_REGION="us-east-1"
   export AWS_PROFILE="admin-profile"
   ```
2. Run the bootstrap plan:
   ```bash
   ./scripts/bootstrap-aws.sh
   # On Windows PowerShell:
   .\scripts\bootstrap-aws.ps1
   ```
3. Apply the bootstrap configuration:
   ```bash
   cd bootstrap/aws
   terraform apply bootstrap.tfplan
   ```
4. Note the output role ARNs (`plan_role_arn`, `apply_role_arn`) and add them to GitHub Actions Secrets:
   - `AWS_PLAN_ROLE_ARN`
   - `AWS_APPLY_ROLE_ARN`

### Azure Bootstrap
1. Authenticate to Azure CLI:
   ```bash
   az login
   az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
   ```
2. Run the bootstrap plan:
   ```bash
   ./scripts/bootstrap-azure.sh
   # On Windows PowerShell:
   .\scripts\bootstrap-azure.ps1
   ```
3. Apply the bootstrap configuration:
   ```bash
   cd bootstrap/azure
   terraform apply bootstrap.tfplan
   ```
4. Configure GitHub Actions Secrets:
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`

---

## 4. Local Verification & Offline Testing

You can format, validate, and test all stacks completely offline without cloud credentials:

```bash
# Fast formatting and syntax checks
./scripts/verify.sh fast

# Full offline test suite (native terraform test with mock providers)
./scripts/verify.sh full
```
