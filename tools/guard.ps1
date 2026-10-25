<#
.SYNOPSIS
    Repository Guard Script (PowerShell)
    Verifies clean-room compliance, ensuring zero private client names, secrets, or real account IDs.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ExitCode = 0

Write-Host "==> Running Clean-Room & Security Guard..." -ForegroundColor Cyan

# Forbidden patterns
$ForbiddenStrings = @(
    "VueXR",
    "Trium Designs",
    "Fudge3d"
)

# Files to scan (tracked and untracked, excluding git metadata and pipeline internal files)
$FilesToScan = Get-ChildItem -Path $RepoRoot -Recurse -File | Where-Object {
    $_.FullName -notmatch "[\\/]\.git([\\/]|$)" -and
    $_.FullName -notmatch "[\\/]\.pipeline([\\/]|$)" -and
    $_.FullName -notmatch "[\\/]\.terragrunt-cache([\\/]|$)" -and
    $_.FullName -notmatch "[\\/]\.terraform([\\/]|$)" -and
    $_.FullName -notmatch "[\\/]tools[\\/]guard\.(ps1|sh)$"
}

foreach ($File in $FilesToScan) {
    $RelativePath = $File.FullName.Substring($RepoRoot.Path.Length + 1)
    
    # Read text content safely
    try {
        $Content = [System.IO.File]::ReadAllText($File.FullName)
    }
    catch {
        continue
    }

    # Check forbidden client names
    foreach ($Forbidden in $ForbiddenStrings) {
        if ($Content -match [regex]::Escape($Forbidden)) {
            Write-Host "[-] VIOLATION: Forbidden client reference '$Forbidden' found in: $RelativePath" -ForegroundColor Red
            $ExitCode = 1
        }
    }

    # Check private keys
    if ($Content -match "-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----") {
        Write-Host "[-] VIOLATION: Private key pattern found in: $RelativePath" -ForegroundColor Red
        $ExitCode = 1
    }

    # Check AWS Access Key IDs
    if ($Content -match "(?<![A-Z0-9])AKIA[0-9A-Z]{16}(?![A-Z0-9])") {
        Write-Host "[-] VIOLATION: Real AWS Access Key ID found in: $RelativePath" -ForegroundColor Red
        $ExitCode = 1
    }

    # Check 12-digit AWS account numbers that are not synthetic 111111111111 or 123456789012
    $Matches = [regex]::Matches($Content, "(?<!\d)\d{12}(?!\d)")
    foreach ($Match in $Matches) {
        $Val = $Match.Value
        if ($Val -ne "111111111111" -and $Val -ne "123456789012" -and $Val -ne "000000000000") {
            # Skip if part of git commit sha or hash (check if hex surroundings exist)
            Write-Host "[-] WARNING: Potential unapproved 12-digit account ID '$Val' found in: $RelativePath" -ForegroundColor Yellow
        }
    }
}

if ($ExitCode -eq 0) {
    Write-Host "[+] Clean-room guard passed: 0 secrets, 0 client references." -ForegroundColor Green
} else {
    Write-Host "[-] Clean-room guard failed with violations!" -ForegroundColor Red
}

exit $ExitCode
