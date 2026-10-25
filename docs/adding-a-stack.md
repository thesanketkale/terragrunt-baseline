# Adding a New Stack to terragrunt-live-template

This walkthrough demonstrates how to add a new modular component (e.g., an SQS Queue or Azure Service Bus) and deploy it across `dev`, `stage`, and `prod` environments without duplicating code.

---

## Step 1: Create the Terraform Module

Create a pure, reusable Terraform module under `modules/<cloud>/<module-name>`:

```
modules/aws/sqs-queue/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── tests/
    └── sqs.tftest.hcl
```

Always include:
- `versions.tf` with pinned required providers.
- Typed `variables.tf` with descriptions and validation blocks.
- Native `terraform test` file using `mock_provider` to ensure offline testability.

---

## Step 2: Create the `_envcommon` Include

Create `_envcommon/<module-name>.hcl`:

```hcl
locals {
  root_config = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  cloud       = local.root_config.locals.is_aws ? "aws" : "azure"
  base_source = "${get_repo_root()}/modules/${local.cloud}/sqs-queue"
}

terraform {
  source = local.base_source
}

inputs = {
  # Default input values shared across all environments
}
```

---

## Step 3: Wire into the Live Hierarchy

Create a deployment leaf unit in `live/aws/<account>/<region>/<env>/<module-name>/terragrunt.hcl`:

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/sqs-queue.hcl"
  expose = true
}

# Optional dependencies on other stacks
dependency "network" {
  config_path = "../network"
  mock_outputs = {
    vpc_id = "vpc-mock123"
  }
}

inputs = {
  queue_name = "app-queue-${local.env}"
}
```

---

## Step 4: Verify Locally

Run the verification harness:

```bash
# Verify formatting and linting
./scripts/verify.sh fast

# Run full module validation and offline tests
./scripts/verify.sh full
```
