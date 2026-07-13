<#
.SYNOPSIS
Runs IaC misconfiguration scanning for Terraform.

.DESCRIPTION
The script prefers a local trivy binary. If Trivy is unavailable, it uses the
official Trivy container image to scan Terraform configuration.
#>

[CmdletBinding()]
param(
    [string]$ScanPath = "terraform",
    [string]$ReportDir = ".build/iac",
    [string]$TrivyImage = "aquasec/trivy:latest",
    [string]$Severity = "HIGH,CRITICAL",
    [string]$TrivyCacheVolume = "devsecops-trivy-cache"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ResolvedReportDir = Join-Path $RepoRoot $ReportDir

New-Item -ItemType Directory -Force -Path $ResolvedReportDir | Out-Null

$JsonReport = Join-Path $ResolvedReportDir "trivy-iac.json"
$TableReport = Join-Path $ResolvedReportDir "trivy-iac-table.txt"

$NativeTrivy = Get-Command trivy -ErrorAction SilentlyContinue

if ($NativeTrivy) {
    trivy config `
        --format json `
        --output $JsonReport `
        (Join-Path $RepoRoot $ScanPath)

    $JsonExit = $LASTEXITCODE

    trivy config `
        --format table `
        --output $TableReport `
        --severity $Severity `
        --exit-code 1 `
        (Join-Path $RepoRoot $ScanPath)

    $TableExit = $LASTEXITCODE
}
else {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        throw "Neither trivy nor docker was found. Install Trivy or Docker Desktop."
    }

    docker version | Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw "Docker is not available to run Trivy IaC scanning. Start Docker Desktop or install Trivy locally."
    }

    $RepoMount = "type=bind,source=$RepoRoot,target=/repo"

    docker run --rm `
        --mount $RepoMount `
        --mount "type=volume,source=$TrivyCacheVolume,target=/root/.cache/trivy" `
        --workdir /repo `
        $TrivyImage config `
        --format json `
        --output /repo/$ReportDir/trivy-iac.json `
        /repo/$ScanPath

    $JsonExit = $LASTEXITCODE

    docker run --rm `
        --mount $RepoMount `
        --mount "type=volume,source=$TrivyCacheVolume,target=/root/.cache/trivy" `
        --workdir /repo `
        $TrivyImage config `
        --format table `
        --output /repo/$ReportDir/trivy-iac-table.txt `
        --severity $Severity `
        --exit-code 1 `
        /repo/$ScanPath

    $TableExit = $LASTEXITCODE
}

if ($JsonExit -ne 0 -and $JsonExit -ne 1) {
    throw "Trivy IaC JSON scan failed to execute correctly. Exit code: $JsonExit."
}

if ($TableExit -ne 0 -and $TableExit -ne 1) {
    throw "Trivy IaC table scan failed to execute correctly. Exit code: $TableExit."
}

if ($TableExit -ne 0) {
    throw "Trivy IaC scan found one or more blocking misconfigurations. Review reports in $ResolvedReportDir."
}

Write-Host "IaC scan completed with no blocking findings."
Write-Host "Reports: $ResolvedReportDir"
