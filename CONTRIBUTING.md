# Contributing to terragrunt-live-template

Thank you for your interest in contributing! We welcome community contributions, bug reports, and architectural discussions.

## Code of Conduct
All contributors and maintainers are expected to adhere to our [Code of Conduct](CODE_OF_CONDUCT.md).

## Clean-Room & Security Standard
- All contributions must be original or under an MIT-compatible open-source license.
- Never commit private client names, proprietary infrastructure details, real account numbers, credentials, or keys.
- Always run `./tools/guard.sh` (or `.\tools\guard.ps1`) before committing.

## Development Workflow
1. Fork and checkout the repository.
2. Install the toolchain pinned in `.tool-versions` (Terraform 1.10.x, Terragrunt 0.63.x, TFLint 0.55.x).
3. Create a feature branch following Conventional Commits (`feat/my-module`, `fix/typo`).
4. Validate changes locally:
   ```bash
   ./scripts/verify.sh fast
   ./scripts/verify.sh full
   ```
5. Ensure all native `terraform test` suites pass offline.
6. Submit a pull request against `main`.
