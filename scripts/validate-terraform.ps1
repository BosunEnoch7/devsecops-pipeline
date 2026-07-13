<#
.SYNOPSIS
Validates Terraform formatting and environment configuration.

.DESCRIPTION
Runs terraform fmt, terraform init with backend disabled, and terraform validate
for each environment folder that contains Terraform files.
#>

[CmdletBinding()]
param(
    [string]$TerraformRoot = "terraform"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ResolvedTerraformRoot = Resolve-Path (Join-Path $RepoRoot $TerraformRoot)

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    throw "Terraform CLI was not found. Install Terraform and ensure it is on PATH."
}

Push-Location $RepoRoot
try {
    terraform fmt -check -recursive $TerraformRoot

    $EnvironmentRoot = Join-Path $ResolvedTerraformRoot "environments"
    $EnvironmentDirs = Get-ChildItem -Path $EnvironmentRoot -Directory

    foreach ($EnvironmentDir in $EnvironmentDirs) {
        $TerraformFiles = Get-ChildItem -Path $EnvironmentDir.FullName -Filter "*.tf" -File

        if ($TerraformFiles.Count -eq 0) {
            Write-Host "Skipping $($EnvironmentDir.Name): no Terraform files found."
            continue
        }

        Write-Host "Validating Terraform environment: $($EnvironmentDir.Name)"
        terraform -chdir="$($EnvironmentDir.FullName)" init -backend=false
        terraform -chdir="$($EnvironmentDir.FullName)" validate
    }
}
finally {
    Pop-Location
}

Write-Host "Terraform validation completed successfully."
