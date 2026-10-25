# ADR-0003: GitHub OIDC Federation and Least-Privilege IAM Architecture

## Status
Accepted

## Date
2026-10-24

## Context
Storing long-lived cloud credentials (such as AWS IAM access keys or Azure service principal client secrets) inside GitHub Actions repository secrets presents severe security risks. Stored credentials do not rotate automatically, lack granular context scoping, and are susceptible to exfiltration if a workflow is compromised.

Modern cloud providers support OpenID Connect (OIDC) identity federation, allowing GitHub Actions workflows to request short-lived, cryptographically signed JSON Web Tokens (JWTs) from GitHub's OIDC token service (`https://token.actions.githubusercontent.com`).

## Decision
1. **Zero Long-Lived Credentials:**
   We eliminate all static cloud credentials from repository and environment secrets. CI/CD pipelines exclusively authenticate via short-lived OIDC federated tokens.

2. **Role & Credential Segregation:**
   We strictly separate **Plan** and **Apply** identities across both clouds:

   - **Plan Identity (Read-Only):**
     - **AWS IAM Role (`github-actions-plan`):**
       - Trust policy condition: `StringEquals: token.actions.githubusercontent.com:sub = "repo:thesanketkale/terragrunt-live-template:pull_request"`.
       - Audience: `sts.amazonaws.com`.
       - Permissions: Attached to `ReadOnlyAccess` policy and state bucket read permissions. Cannot mutate or destroy resources.
     - **Azure Federated Credential (`github-actions-plan`):**
       - Subject claim: `repo:thesanketkale/terragrunt-live-template:pull_request`.
       - Roles: `Reader` at subscription or resource group scope, plus `Storage Blob Data Reader` on the state storage account.

   - **Apply Identity (Environment-Scoped Mutation):**
     - **AWS IAM Role (`github-actions-apply-<env>`):**
       - Trust policy condition: `StringEquals: token.actions.githubusercontent.com:sub = "repo:thesanketkale/terragrunt-live-template:environment:<env>"`.
       - Permissions: Scoped infrastructure modification policy targeting resources tagged with that environment.
     - **Azure Federated Credential (`github-actions-apply-<env>`):**
       - Subject claim: `repo:thesanketkale/terragrunt-live-template:environment:<env>`.
       - Roles: `Contributor` scoped to the target environment resource group, plus `Storage Blob Data Contributor` on the state storage account.

3. **Workflow Security Rules:**
   - Workflows set top-level `permissions: {}` to prevent accidental token escalation.
   - The `id-token: write` permission is granted strictly to specific jobs performing OIDC authentication.
   - We avoid `pull_request_target` triggers entirely for untrusted PRs, relying instead on standard `pull_request` triggers with read-only plan permissions.

## Consequences

### Positive
- **No Secret Rotation Burden:** Eliminates credential leakage, key expiry failures, and secret rotation overhead.
- **Auditability:** Cloud audit logs (AWS CloudTrail, Azure Activity Log) record precise GitHub workflow run IDs, commit SHAs, and actor identities in federated session names.
- **Strict Blast-Radius Limitation:** Pull requests cannot modify infrastructure; applies can only run within their approved GitHub Environments.

### Negative / Trade-offs
- One-time bootstrap is required per cloud account to establish the OIDC identity provider and base roles prior to running automated pipelines.
