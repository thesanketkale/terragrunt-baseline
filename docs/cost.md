# Cost Management & Architecture Controls

This document details the cost optimization strategies and architectural toggles in `terragrunt-live-template`.

---

## 1. Minimal Defaults Strategy

Infrastructure templates often incur substantial idle cloud costs by provisioning high-availability (HA) gateways and resources by default. `terragrunt-live-template` defaults to minimal, cost-conscious configurations:

| Component | Cloud | Production Setting | Non-Production Setting (`dev`, `stage`) | Monthly Savings |
| :--- | :--- | :--- | :--- | :--- |
| **NAT Gateways** | AWS | Multi-AZ (1 per AZ) | `single_nat_gateway = true` (1 shared NAT) | ~$65/mo per eliminated NAT |
| **VPC Endpoints** | AWS | Gateway Endpoints (Free) | Gateway Endpoints (Free) | Free direct routing for S3/DynamoDB |
| **State Locking** | AWS | S3 Native Lockfile | S3 Native Lockfile | $0/mo (No DynamoDB table costs) |
| **Storage Account** | Azure | Standard LRS | Standard LRS | Lowest replication storage tier |

---

## 2. Automated Budget Alerts

Every environment provisions automated budget alerts:
- **AWS Budgets:** Monthly cost budgets configured per tier (`$50` in dev, `$150` in stage, `$500` in prod). Alerts trigger via Email and SNS at 50%, 80%, and 100% of forecast/actual spend.
- **Azure Consumption Budgets:** Integrated with Azure Monitor Action Groups, issuing immediate email alerts upon threshold breach.
