<#
.SYNOPSIS
    Azure One-Time Bootstrap Script (PowerShell)
    Idempotently provisions initial Storage Account state backend and Entra ID application with local state.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$BootstrapDir = Join-Path $RepoRoot "bootstrap\azure"

Write-Host "==> [Azure Bootstrap] Initializing local Terraform state in $BootstrapDir..." -ForegroundColor Cyan
Push-Location $BootstrapDir
try {
    terraform init -input=false
    Write-Host "==> [Azure Bootstrap] Running plan for Storage Account state backend and Entra ID OIDC..." -ForegroundColor Cyan
    terraform plan -out=bootstrap.tfplan -input=false
    Write-Host "`n[+] Plan complete. Run 'terraform apply bootstrap.tfplan' to create foundational resources." -ForegroundColor Green
}
finally {
    Pop-Location
}
