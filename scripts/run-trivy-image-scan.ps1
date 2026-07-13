<#
.SYNOPSIS
Runs Trivy vulnerability scanning against a container image.

.DESCRIPTION
The script prefers a locally installed trivy binary. If trivy is unavailable,
it exports the Docker image to a tarball and scans that tarball with the official
Trivy container image. This avoids relying on a Linux docker.sock path on Windows.

Reports are written to .build/trivy by default.
#>

[CmdletBinding()]
param(
    [string]$Image = "secure-delivery-api:offline-test",
    [string]$ReportDir = ".build/trivy",
    [string]$TrivyImage = "aquasec/trivy:latest",
    [string]$Severity = "HIGH,CRITICAL",
    [string]$PackageTypes = "os,library",
    [string]$TrivyCacheVolume = "devsecops-trivy-cache"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ResolvedReportDir = Join-Path $RepoRoot $ReportDir

New-Item -ItemType Directory -Force -Path $ResolvedReportDir | Out-Null

$JsonReport = Join-Path $ResolvedReportDir "trivy-image.json"
$TableReport = Join-Path $ResolvedReportDir "trivy-image-table.txt"
$ImageTar = Join-Path $ResolvedReportDir "image.tar"

function Assert-TrivyExecutionExitCode {
    param(
        [int]$ExitCode,
        [string]$ReportKind
    )

    if ($ExitCode -ne 0 -and $ExitCode -ne 1) {
        throw "Trivy $ReportKind scan failed to execute correctly. Exit code: $ExitCode."
    }
}

$NativeTrivy = Get-Command trivy -ErrorAction SilentlyContinue

if ($NativeTrivy) {
    & trivy image `
        --scanners vuln `
        --format json `
        --output $JsonReport `
        --pkg-types $PackageTypes `
        $Image

    $JsonExit = $LASTEXITCODE
    Assert-TrivyExecutionExitCode -ExitCode $JsonExit -ReportKind "JSON"

    & trivy image `
        --scanners vuln `
        --format table `
        --output $TableReport `
        --severity $Severity `
        --ignore-unfixed `
        --exit-code 1 `
        --pkg-types $PackageTypes `
        $Image

    $TableExit = $LASTEXITCODE
    Assert-TrivyExecutionExitCode -ExitCode $TableExit -ReportKind "table"
}
else {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        throw "Neither trivy nor docker was found. Install Trivy or Docker Desktop."
    }

    docker version | Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw "Docker is not available to run Trivy. Start Docker Desktop or install Trivy locally."
    }

    & docker image inspect $Image | Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw "Image '$Image' does not exist locally. Build it before scanning."
    }

    & docker save --output $ImageTar $Image

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to export image '$Image' for Trivy scanning."
    }

    $RepoMount = "type=bind,source=$RepoRoot,target=/repo"
    $ContainerInput = "/repo/$ReportDir/image.tar"

    & docker run --rm `
        --mount $RepoMount `
        --mount "type=volume,source=$TrivyCacheVolume,target=/root/.cache/trivy" `
        --workdir /repo `
        $TrivyImage image `
        --input $ContainerInput `
        --scanners vuln `
        --format json `
        --output /repo/$ReportDir/trivy-image.json `
        --pkg-types $PackageTypes

    $JsonExit = $LASTEXITCODE
    Assert-TrivyExecutionExitCode -ExitCode $JsonExit -ReportKind "JSON"

    & docker run --rm `
        --mount $RepoMount `
        --mount "type=volume,source=$TrivyCacheVolume,target=/root/.cache/trivy" `
        --workdir /repo `
        $TrivyImage image `
        --input $ContainerInput `
        --scanners vuln `
        --format table `
        --output /repo/$ReportDir/trivy-image-table.txt `
        --severity $Severity `
        --ignore-unfixed `
        --exit-code 1 `
        --pkg-types $PackageTypes

    $TableExit = $LASTEXITCODE
    Assert-TrivyExecutionExitCode -ExitCode $TableExit -ReportKind "table"
}

if ($TableExit -ne 0) {
    throw "Trivy found one or more blocking vulnerabilities. Review reports in $ResolvedReportDir."
}

Write-Host "Trivy image scan completed with no blocking findings."
Write-Host "Reports: $ResolvedReportDir"
