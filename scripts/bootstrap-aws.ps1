<#
.SYNOPSIS
    AWS One-Time Bootstrap Script (PowerShell)
    Idempotently provisions initial S3 state bucket and GitHub Actions IAM OIDC provider with local state.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$BootstrapDir = Join-Path $RepoRoot "bootstrap\aws"

Write-Host "==> [AWS Bootstrap] Initializing local Terraform state in $BootstrapDir..." -ForegroundColor Cyan
Push-Location $BootstrapDir
try {
    terraform init -input=false
    Write-Host "==> [AWS Bootstrap] Running plan for S3 state backend and GitHub Actions OIDC..." -ForegroundColor Cyan
    terraform plan -out=bootstrap.tfplan -input=false
    Write-Host "`n[+] Plan complete. Run 'terraform apply bootstrap.tfplan' to create foundational resources." -ForegroundColor Green
}
finally {
    Pop-Location
}
