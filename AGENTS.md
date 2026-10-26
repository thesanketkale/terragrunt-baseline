# AGENTS.md: terragrunt-baseline

Shared rules for every AI agent on this repo, in Claude Code (through CLAUDE.md) and Google Antigravity (which reads this file directly). Keep it under ~150 lines. It is read at the start of every run. Write `TBD` rather than guessing.

## Project
- What it is: Multi-environment Terragrunt baseline for AWS and Azure: remote state, GitHub OIDC federation without stored secrets, network and budget modules, and plan, apply and drift-detection pipelines.
- Users: Cloud infrastructure, platform, and DevOps engineers managing multi-cloud environments with least privilege.
- Related repos and contracts: Consumes reusable workflows from `reusable-workflows`; referenced by `php-api-foundation` and `dotnet-web-foundation`.

## Stack packs
<!-- One per line. Agents load {skills dir}/stack-<name>/SKILL.md for each. -->
- terraform-infra
- github-actions

## Commands
- Install: None (managed via `.tool-versions` / mise)
- Run locally: None (infrastructure repository)
- Verify fast: `bash scripts/verify.sh fast` (Windows PowerShell: `./scripts/verify.ps1 fast`)
- Verify full: `bash scripts/verify.sh full` (Windows PowerShell: `./scripts/verify.ps1 full`)
- Disposable database: None

## Git
- Base branch: main
- Branches: `feat/<slug>`, `fix/<slug>`, `chore/<slug>`
- PR: manual

## Conventions
- This is a public MIT repository written clean-room: no code, assets, names or data from client or employer projects. Sample data is synthetic.
- The standards and this repository's requirements are in `.pipeline/SPEC.md` (local, never committed). Requirement IDs appear in AC lines as `AC-n [ID]` and in test names.
- Docs describe only what exists and was run. What an agent cannot run (push, live cloud, signing, a Unity Editor, GitHub settings) is a `[USER]` item in `docs/release-checklist.md` and is never described as tested.
- GitHub Actions: top-level `permissions: {}` plus minimal per-job permissions; `timeout-minutes` and `concurrency` on every workflow; actions pinned to a full SHA with the version in a comment; explicit `shell:`; LF line endings; no `${{ github.event.* }}` inside `run:` (use `env:`); OIDC for cloud login. Check with `actionlint`.
- Commits are small and follow `<type>(<scope>): <goal> [step N]`. Dates are real and history is never rewritten.
- Dependencies need MIT-compatible licences. Record stack choices and open-decision outcomes in `docs/adr/`.
- Identifiers in examples are fake: account `111111111111`, subscription `00000000-0000-0000-0000-000000000000`, domain `example.com`, repository `OWNER/REPO`.
- Every module variable has a type, description and validation. Every resource carries the shared tags. State resources set `prevent_destroy`.
- Use the current Terragrunt command form (`terragrunt run --all`, `terragrunt hcl fmt`). Check `terragrunt --version` and its help before writing a command.
- Bootstrap scripts are idempotent, shellcheck-clean and dry-run by default. They change nothing without `--yes`.
- Checkov skips live in one baseline file, and each has a written reason.

## Design
- None (infrastructure repository, `/ship` flag `--no-design`).

## Safety: agents never do these. They prepare the command and hand it over.
- Deploy, publish, release, upload, sign or notarize builds.
- Push to the base branch, force-push, rewrite published history.
- Safety additions: never push, tag, create releases, change GitHub settings or run `git filter-repo`; write the command into `docs/release-checklist.md` instead. Never print secret values: show only file, line, rule and the last four characters.
- Agents never run `apply`, `destroy`, `import` or any state command, and never run a bootstrap script with `--yes`. The only Terraform commands used are `fmt`, `validate`, `test` with `mock_provider`, and `plan` against nothing. No cloud credentials are used or created.

## Known baseline failures
<!-- Pre-existing failures moved out of `fast`, with a note on why. Remove as they get fixed. -->
- None.

## Lessons
<!-- One line each, added only with the user's approval after a review found a repeatable mistake.
     Format: - [area] Do X, not Y, because Z. -->
