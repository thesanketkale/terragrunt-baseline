<#
.SYNOPSIS
    Verification Script for terragrunt-live-template (PowerShell)
.PARAMETER Mode
    fast or full (default: fast)
#>

[CmdletBinding()]
param(
    [ValidateSet("fast", "full")]
    [string]$Mode = "fast"
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $RepoRoot

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

try {
    # 1. Clean-Room Guard
    Write-Step "Checking Clean-Room and Secret Guard"
    & "$RepoRoot\tools\guard.ps1"

    # 2. Terraform Format Check
    Write-Step "Checking Terraform Formatting"
    $TfFiles = Get-ChildItem -Path $RepoRoot -Recurse -Filter "*.tf" | Where-Object { $_.FullName -notmatch "[\\/]\.(terraform|terragrunt-cache)[\\/]" }
    if ($TfFiles.Count -gt 0) {
        terraform fmt -check -recursive
        if ($LASTEXITCODE -ne 0) {
            throw "terraform fmt check failed!"
        }
        Write-Host "[+] Terraform files properly formatted." -ForegroundColor Green
    } else {
        Write-Host "[*] No .tf files found to format." -ForegroundColor Gray
    }

    # 3. Terragrunt HCL Format Check
    Write-Step "Checking Terragrunt HCL Formatting"
    $HclFiles = Get-ChildItem -Path $RepoRoot -Recurse -Filter "*.hcl" | Where-Object { $_.FullName -notmatch "[\\/]\.(terraform|terragrunt-cache)[\\/]" }
    if ($HclFiles.Count -gt 0) {
        # Check terragrunt syntax compatibility
        try {
            terragrunt hclfmt --terragrunt-check 2>$null
            if ($LASTEXITCODE -ne 0) {
                # Try newer terragrunt command syntax
                terragrunt hcl fmt --check
            }
        }
        catch {
            terragrunt hcl fmt --check
        }
        if ($LASTEXITCODE -ne 0) {
            throw "terragrunt hclfmt check failed!"
        }
        Write-Host "[+] Terragrunt HCL files properly formatted." -ForegroundColor Green
    } else {
        Write-Host "[*] No .hcl files found to format." -ForegroundColor Gray
    }

    # 4. GitHub Actions Workflow Syntax Check
    Write-Step "Checking Workflow YAML Syntax"
    $WfFiles = Get-ChildItem -Path "$RepoRoot\.github\workflows" -Filter "*.yml" -ErrorAction SilentlyContinue
    if ($WfFiles.Count -gt 0) {
        $PyCmd = Get-Command python -ErrorAction SilentlyContinue
        if ($PyCmd) {
            & python -c "import glob, yaml, sys; [yaml.safe_load(open(f, encoding='utf-8')) for f in glob.glob('.github/workflows/*.y*ml')]"
            if ($LASTEXITCODE -ne 0) {
                throw "Workflow YAML parsing error detected!"
            }
            Write-Host "[+] Workflows are syntactically valid YAML." -ForegroundColor Green
        }
    }

    if ($Mode -eq "full") {
        # 5. Terraform Validation across all modules
        Write-Step "Validating Terraform Modules"
        $ModuleDirs = Get-ChildItem -Path "$RepoRoot\modules", "$RepoRoot\bootstrap" -Directory -Recurse | Where-Object {
            Test-Path (Join-Path $_.FullName "main.tf")
        }

        foreach ($dir in $ModuleDirs) {
            $RelPath = $dir.FullName.Substring($RepoRoot.Path.Length + 1)
            Write-Host "  Validating module: $RelPath" -ForegroundColor Yellow
            Push-Location $dir.FullName
            try {
                terraform init -backend=false -input=false > $null 2>&1
                terraform validate -no-color
                if ($LASTEXITCODE -ne 0) {
                    throw "terraform validate failed in $RelPath"
                }
            }
            finally {
                Pop-Location
            }
        }
        Write-Host "[+] All modules successfully validated." -ForegroundColor Green

        # 6. TFLint
        $TfLintCmd = Get-Command tflint -ErrorAction SilentlyContinue
        if ($TfLintCmd) {
            Write-Step "Running TFLint"
            tflint --recursive
            if ($LASTEXITCODE -ne 0) {
                Write-Host "[-] TFLint warnings/errors detected." -ForegroundColor Yellow
            } else {
                Write-Host "[+] TFLint passed." -ForegroundColor Green
            }
        }

        # 7. Native Terraform Tests (mock_provider)
        Write-Step "Running Native Terraform Tests (terraform test)"
        $TestDirs = Get-ChildItem -Path "$RepoRoot\modules" -Directory -Recurse | Where-Object {
            Test-Path (Join-Path $_.FullName "tests")
        }

        foreach ($dir in $TestDirs) {
            $RelPath = $dir.FullName.Substring($RepoRoot.Path.Length + 1)
            Write-Host "  Testing module: $RelPath" -ForegroundColor Yellow
            Push-Location $dir.FullName
            try {
                terraform test -no-color
                if ($LASTEXITCODE -ne 0) {
                    throw "terraform test failed in $RelPath"
                }
            }
            finally {
                Pop-Location
            }
        }
        Write-Host "[+] Native terraform tests passed." -ForegroundColor Green
    }

    Write-Host "`n[+] Verification ($Mode) COMPLETED SUCCESSFULLY!" -ForegroundColor Green
}
catch {
    Write-Host "`n[-] Verification FAILED: $_" -ForegroundColor Red
    exit 1
}
finally {
    Pop-Location
}
