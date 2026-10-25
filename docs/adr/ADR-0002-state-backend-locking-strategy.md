# ADR-0002: Remote State Backend and Distributed Locking Strategy for AWS and Azure

## Status
Accepted

## Date
2026-10-24

## Context
State management is the critical foundation of Infrastructure-as-Code. Storing state locally or unencrypted exposes infrastructure secrets and allows concurrent modifications that can corrupt state files.

In AWS, state has traditionally been stored in Amazon S3, with distributed locking managed via an Amazon DynamoDB table. With Terraform 1.10+ and OpenTofu 1.7+, native S3 locking (`use_lockfile = true`) is supported via S3 conditional writes, eliminating the need to provision and maintain a separate DynamoDB table.

In Azure, state is stored in Azure Blob Storage. Access must be hardened to prevent unauthorized inspection, and distributed locking must use native blob leases with Entra ID authentication rather than shared storage access keys.

## Decision
1. **AWS Remote State & Locking:**
   - **S3 Bucket Configuration:** Dedicated per-account S3 bucket with:
     - S3 default encryption using AES256 or KMS.
     - Public Access Block (`BlockPublicAcls`, `IgnorePublicAcls`, `BlockPublicPolicy`, `RestrictPublicBuckets`) set to `true`.
     - Bucket policy strictly enforcing TLS (`aws:SecureTransport: "false"` -> `Deny`).
     - S3 Object Versioning enabled to facilitate instant rollback if state corruption occurs.
     - `prevent_destroy = true` lifecycle rule to prevent accidental deletion.
   - **Locking Strategy:**
     - Primary: Native S3 lockfile (`use_lockfile = true`) enabled by default in `root.hcl` for modern Terraform/OpenTofu installations.
     - Fallback: The `modules/aws/state-backend` module includes an optional DynamoDB lock table toggle (`create_dynamodb_lock_table = false` by default, settable to `true`) for teams maintaining older Terraform (<1.10) versions.

2. **Azure Remote State & Locking:**
   - **Storage Account Configuration:**
     - Dedicated Resource Group per environment/subscription.
     - Standard LRS (Locally Redundant Storage) storage account.
     - `min_tls_version = "TLS1_2"`.
     - `shared_access_key_enabled = false` (enforcing modern Entra ID token-based authentication).
     - Soft delete and blob versioning enabled for data protection.
     - `prevent_destroy = true` lifecycle rule.
   - **Locking Strategy:**
     - Distributed locking is handled natively by Azure Blob Storage via storage container leases.
     - Access rights are granted through Entra ID role assignments (`Storage Blob Data Contributor`).

## Consequences

### Positive
- **Cost Reduction:** AWS S3 native lockfiles eliminate DynamoDB read/write capacity and table management overhead.
- **Enhanced Security:** Shared access keys in Azure are completely disabled; state operations rely solely on short-lived Entra ID tokens.
- **Accidental Deletion Prevention:** All state storage resources are guarded by `prevent_destroy = true`.

### Negative / Trade-offs
- Native S3 lockfile requires Terraform >= 1.10 or OpenTofu >= 1.7. Users on older toolchains must enable the DynamoDB table flag in the state backend module.
- Entra ID access to Azure Blob Storage requires appropriate RBAC role assignments (`Storage Blob Data Contributor`) prior to initializing the backend.
