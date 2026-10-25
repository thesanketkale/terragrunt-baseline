# ADR-0001: IaC Toolchain, OpenTofu/Terraform Dual Compatibility, and Terragrunt Architecture

## Status
Accepted

## Date
2026-10-24

## Context
Managing enterprise cloud infrastructure across multiple public cloud providers (AWS and Azure) and multiple tiers (`dev`, `stage`, `prod`) quickly leads to code duplication, configuration drift, and maintenance overhead when using plain Terraform. Standard Terraform workspaces do not provide hard isolation boundaries between environments (such as dedicated AWS accounts or Azure subscriptions), nor do they keep remote backend definitions DRY.

Furthermore, following the HashiCorp BSL license change, organizations require flexibility in choosing between upstream HashiCorp Terraform and the Linux Foundation's open-source OpenTofu engine without rewriting their infrastructure codebase.

## Decision
1. **Orchestration with Terragrunt:**
   We adopt **Terragrunt** as the thin orchestration layer above Terraform / OpenTofu. Terragrunt is configured to:
   - Generate backend configuration (`remote_state`) and provider blocks automatically via `root.hcl`.
   - Provide hierarchical variable inheritance using `read_terragrunt_config(find_in_parent_folders(...))`, passing account, region, and environment variables into stack modules.
   - Decouple module definitions (`modules/`) from environment deployments (`live/`), ensuring zero repetition via `_envcommon/` shared includes.
   - Use `mock_outputs` in all `dependency` blocks to allow offline syntax validation and planning without requiring pre-existing infrastructure.

2. **Dual Engine Support (Terraform >= 1.10 & OpenTofu >= 1.8):**
   - The codebase strictly avoids engine-specific proprietary features that break portability.
   - Version pinning is declared via `.tool-versions` (compatible with `asdf` and `mise`).
   - Standard Terraform CLI and OpenTofu CLI commands are supported interchangeably via `TERRAGRUNT_TFPATH=tofu` or `TERRAGRUNT_TFPATH=terraform`.

3. **Terragrunt CLI Syntax Version Handling:**
   - In Terragrunt v0.64+, the command syntax evolved from `run-all` to `run --all` and from `hclfmt` to `hcl fmt`.
   - All automation scripts (`scripts/verify.sh`, `scripts/verify.ps1`, CI workflows) gracefully support both command formats:
     ```bash
     terragrunt hcl fmt --check 2>/dev/null || terragrunt hclfmt --terragrunt-check
     ```

## Consequences

### Positive
- **DRY Architecture:** Eliminates duplicate backend, provider, and variable declarations across 24+ live stacks.
- **Provider Agility:** Teams can seamlessly switch between Terraform and OpenTofu without altering HCL definitions.
- **Fail-Fast Offline Validation:** Offline validation works out-of-the-box thanks to mock outputs in Terragrunt dependencies.

### Negative / Trade-offs
- Requires installing Terragrunt alongside Terraform/OpenTofu on developer workstations and CI runners.
- Slight learning curve for engineers familiar only with vanilla Terraform directory layouts.

## Alternatives Considered & Rejected
- **Vanilla Terraform with Workspaces:** Rejected because workspaces share the same backend state bucket and cannot easily isolate distinct cloud accounts or provider blocks per environment.
- **CDK for Terraform (CDKTF):** Rejected due to additional language runtimes (Node.js/Python), complex synthesis steps, and reduced readability for pure infrastructure engineers.
- **Pulumi:** Rejected to maintain standard HCL declarative semantics and avoid vendor lock-in.
