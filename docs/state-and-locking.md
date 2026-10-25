# Remote State & Distributed Locking Strategy

This document explains remote state management, encryption, versioning, and locking mechanisms across AWS and Azure in `terragrunt-live-template`.

---

## 1. Amazon Web Services (AWS)

### S3 Native Lockfile (Terraform 1.10+ / OpenTofu 1.7+)
Historically, Terraform state locking in AWS required an Amazon DynamoDB table. With Terraform 1.10+, Amazon S3 supports native locking via conditional writes.

In `root.hcl`:
```hcl
remote_state {
  backend = "s3"
  config = {
    encrypt      = true
    bucket       = "terragrunt-state-${local.account_id}-${local.aws_region}"
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = local.aws_region
    use_lockfile = true
  }
}
```

### Security & Integrity Controls
- **Encryption:** Server-Side Encryption with AES256 or Customer Managed KMS Key.
- **Versioning:** S3 Bucket Versioning is permanently enabled.
- **Public Access Block:** All 4 public access block settings (`BlockPublicAcls`, `IgnorePublicAcls`, `BlockPublicPolicy`, `RestrictPublicBuckets`) are enforced.
- **TLS Enforcement:** Bucket policy denies all non-TLS requests (`aws:SecureTransport: "false"`).
- **Accidental Deletion Prevention:** All state buckets enforce `prevent_destroy = true`.

---

## 2. Microsoft Azure

### Azure Blob Storage with Entra ID Authentication
Azure remote state is managed through dedicated Storage Accounts and private Blob Containers.

In `root.hcl`:
```hcl
remote_state {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-tfstate-${local.location}-${local.env}"
    storage_account_name = "sttfstate${local.env}${substr(replace(local.subscription_id, "-", ""), 0, 8)}"
    container_name       = "tfstate"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
    use_azuread_auth     = true
  }
}
```

### Security & Integrity Controls
- **Shared Access Keys Disabled:** `shared_access_key_enabled = false` enforces Entra ID token-based authentication.
- **TLS Enforcement:** `min_tls_version = "TLS1_2"`.
- **Soft Delete & Versioning:** Blob versioning and 30-day soft delete policies protect state files from accidental destruction.
- **Lease-Based Locking:** Blob storage natively acquires 60-second renewable exclusive leases during write operations.
