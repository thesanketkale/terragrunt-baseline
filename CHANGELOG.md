# Changelog

All notable changes to `terragrunt-live-template` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-10-25

### Added
- **Repository Scaffolding:** EditorConfig, Git attributes with LF normalization, .gitignore for Terraform/Terragrunt, tool version pinning (`.tool-versions`), and MIT License.
- **Clean-Room & Guard Automation:** `tools/guard.sh` and `tools/guard.ps1` enforcing clean-room compliance and secret scanning.
- **Architecture Decision Records (ADRs):**
  - `ADR-0001`: IaC Toolchain, OpenTofu/Terraform Dual Compatibility, and Terragrunt Architecture.
  - `ADR-0002`: Remote State Backend and Distributed Locking Strategy for AWS and Azure.
  - `ADR-0003`: GitHub OIDC Federation and Least-Privilege IAM Architecture.
- **System Architecture Specification:** Detailed C4 architecture specification in `docs/architecture.md`.
- **Root Terragrunt & Stack Common Inclusions:**
  - `root.hcl`: Dynamic provider generation and remote state backend generation for AWS S3 and Azure Blob.
  - `_envcommon/`: Reusable stack definitions for state backend, OIDC federation, networking, and budget alerts.
- **AWS Terraform Modules (`modules/aws/`):**
  - `state-backend`: S3 bucket with versioning, SSE-S3/KMS encryption, Public Access Block, TLS enforcement, native S3 lockfile (`use_lockfile = true`), and optional DynamoDB lock table fallback.
  - `github-oidc`: IAM OIDC Identity Provider with read-only Plan role (pull requests) and environment-scoped Apply roles (`dev`, `stage`, `prod`).
  - `network`: Modular VPC across 2-3 AZs with public, private, and data subnets; single-NAT cost toggle; and free Gateway Endpoints for S3 and DynamoDB.
  - `budget-alerts`: AWS Budgets with multi-threshold alerts (50%, 80%, 100%) via email and SNS.
- **Azure Terraform Modules (`modules/azure/`):**
  - `state-backend`: Dedicated Resource Group, Standard LRS Storage Account, minimum TLS 1.2, shared access keys disabled (Entra ID only), blob versioning, soft delete, and lease-based locking.
  - `github-oidc`: Entra ID Application, Service Principal, and Federated Identity Credentials for pull requests and environment deployments with Reader, Contributor, and Storage Blob Data roles.
  - `network`: Virtual Network with public, private, and data subnets, default-deny Network Security Groups (NSGs), and optional NAT Gateway.
  - `budget-alerts`: Azure Consumption Budgets with Action Group email notifications.
- **Multi-Environment Live Hierarchies (`live/`):**
  - `live/aws/111111111111/us-east-1/`: Multi-tier deployment units (`dev`, `stage`, `prod`) with `mock_outputs` for offline planning.
  - `live/azure/00000000-0000-0000-0000-000000000000/eastus/`: Multi-tier deployment units (`dev`, `stage`, `prod`) with `mock_outputs`.
- **Bootstrap Stacks & Automation:**
  - One-time local state bootstrap stacks in `bootstrap/aws` and `bootstrap/azure`.
  - Idempotent bootstrap automation scripts (`scripts/bootstrap-aws.sh`, `scripts/bootstrap-aws.ps1`, `scripts/bootstrap-azure.sh`, `scripts/bootstrap-azure.ps1`).
- **Offline Native Testing (`*.tftest.hcl`):**
  - Native `terraform test` suites using `mock_provider` across all 8 modules, executing 100% offline without cloud credentials.
  - Static analysis configuration via `.tflint.hcl` and `.checkov.baseline.json`.
- **GitHub Actions CI/CD & Governance:**
  - `ci.yml`: Clean-room guard, HCL formatting, module validation, TFLint, mock tests, and Gitleaks scanning.
  - `plan.yml`: Speculative plans for pull requests with sticky comment summaries.
  - `apply.yml`: Environment-scoped deployments (`dev`, `stage`, `prod`) with approval gates.
  - `drift.yml`: Nightly automated drift detection with GitHub issue creation.
  - `release-please.yml`: Automated changelog generation and release tagging.
  - Repository governance: Dependabot, CODEOWNERS, issue templates, PR template.
- **Comprehensive Documentation & Runbooks:**
  - 11-point `README.md` with honest alternative comparisons, configuration table, and Mermaid diagram.
  - `docs/getting-started.md`, `docs/oidc-trust-model.md`, `docs/state-and-locking.md`, `docs/adding-a-stack.md`, `docs/cost.md`, `docs/destroy-runbook.md`, and deterministic `docs/verification-log.md`.
  - Community governance: `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`.

[0.1.0]: https://github.com/thesanketkale/terragrunt-live-template/releases/tag/v0.1.0
