# GitHub Actions OIDC Trust Model & Security Architecture

## 1. Threat Model & Design Rationale

Traditional CI/CD pipelines store long-lived credentials (`AWS_ACCESS_KEY_ID`, `ARM_CLIENT_SECRET`) inside GitHub repository secrets. This presents critical vulnerabilities:
1. **Exfiltration Risk:** Compromised workflows or malicious pull requests can echo secrets into logs or exfiltrate them.
2. **Credential Rotation Overhead:** Rotation is manual and prone to breaking deployments.
3. **Broad Blast Radius:** Static keys often possess full administrative privileges across all environments.

By integrating OpenID Connect (OIDC), GitHub Actions issues cryptographic JSON Web Tokens (JWTs) for each workflow job, which AWS STS and Microsoft Entra ID exchange for short-lived credentials.

---

## 2. Subject Claim Scoping Matrix

To enforce least privilege, we separate identities into read-only **Plan** and environment-scoped **Apply** roles:

| Cloud | Role / Credential Name | Permitted Subject Claim (`sub`) | Granted Permissions | Trigger Context |
| :--- | :--- | :--- | :--- | :--- |
| **AWS** | `github-actions-plan-dev` | `repo:<org>/<repo>:pull_request` | `ReadOnlyAccess` + S3 state read | Pull Request checks (`plan.yml`) |
| **AWS** | `github-actions-apply-dev` | `repo:<org>/<repo>:environment:dev` | Scoped mutation (EC2, VPC, S3) | Push to `main` (`apply.yml`) |
| **Azure** | `github-actions-plan-pr` | `repo:<org>/<repo>:pull_request` | `Reader` + `Storage Blob Data Reader` | Pull Request checks (`plan.yml`) |
| **Azure** | `github-actions-apply-dev` | `repo:<org>/<repo>:environment:dev` | `Contributor` + `Storage Blob Data Contributor` | Push to `main` (`apply.yml`) |

---

## 3. GitHub Actions Token Guardrails

All repository workflows adhere to strict token security:
- **Default Zero Permissions:** Workflows declare `permissions: {}` at the top level.
- **Explicit Job Tokens:** The `id-token: write` permission is granted only to jobs requesting OIDC tokens.
- **Untrusted Checkout Protection:** We avoid `pull_request_target` triggers on untrusted code. Standard `pull_request` triggers run only with the read-only Plan role.
