## Description
<!-- Provide a concise description of the changes introduced by this pull request. -->

## Type of Change
- [ ] `feat`: New infrastructure module or live stack configuration
- [ ] `fix`: Bug fix in existing Terraform module or Terragrunt hierarchy
- [ ] `docs`: Documentation, ADR, or runbook additions
- [ ] `ci`: GitHub Actions pipeline or security scanner updates
- [ ] `chore`: Maintenance, version pinning, or dependency updates

## Verification Checklist
- [ ] Clean-room check passed (`./tools/guard.sh` or `.\tools\guard.ps1`)
- [ ] Formatting verified (`terraform fmt -check -recursive` and `terragrunt hcl fmt --check`)
- [ ] Static analysis clean (`tflint --recursive`)
- [ ] Native tests passing (`terraform test` offline with `mock_provider`)
- [ ] No hardcoded secrets, client names, or real cloud credentials committed

## Notes for Reviewers
<!-- Mention any specific architecture choices, cost impacts, or owner-verification steps. -->
