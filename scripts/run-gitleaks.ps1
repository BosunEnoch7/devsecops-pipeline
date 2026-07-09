<#
.SYNOPSIS
Runs Gitleaks secret scanning for the repository.

.DESCRIPTION
The script prefers a locally installed gitleaks binary. If gitleaks is not
available on PATH, it falls back to the official Gitleaks container image.

Reports are written to .build/gitleaks by default and secrets are redacted.
#>

[CmdletBinding()]
param(
    [string]$ConfigPath = "security/gitleaks/gitleaks.toml",
    [string]$ReportDir = ".build/gitleaks",
    [string]$GitleaksImage = "ghcr.io/gitleaks/gitleaks:latest"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ResolvedConfig = Resolve-Path (Join-Path $RepoRoot $ConfigPath)
$ResolvedReportDir = Join-Path $RepoRoot $ReportDir

New-Item -ItemType Directory -Force -Path $ResolvedReportDir | Out-Null

$JsonReport = Join-Path $ResolvedReportDir "gitleaks.json"
$JunitReport = Join-Path $ResolvedReportDir "gitleaks-junit.xml"

$NativeGitleaks = Get-Command gitleaks -ErrorAction SilentlyContinue

function Assert-GitleaksExitCode {
    param(
        [int]$ExitCode,
        [string]$ReportKind
    )

    if ($ExitCode -ne 0 -and $ExitCode -ne 1) {
        throw "Gitleaks $ReportKind scan failed to execute correctly. Exit code: $ExitCode."
    }
}

if ($NativeGitleaks) {
    & gitleaks git `
        --source $RepoRoot `
        --config $ResolvedConfig `
        --redact `
        --report-format json `
        --report-path $JsonReport `
        --exit-code 1

    $JsonExit = $LASTEXITCODE
    Assert-GitleaksExitCode -ExitCode $JsonExit -ReportKind "JSON"

    & gitleaks git `
        --source $RepoRoot `
        --config $ResolvedConfig `
        --redact `
        --report-format junit `
        --report-path $JunitReport `
        --exit-code 1

    $JunitExit = $LASTEXITCODE
    Assert-GitleaksExitCode -ExitCode $JunitExit -ReportKind "JUnit"
}
else {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        throw "Neither gitleaks nor docker was found. Install Gitleaks or Docker Desktop."
    }

    docker version | Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw "Docker is not available to run the Gitleaks container. Start Docker Desktop or install Gitleaks locally."
    }

    $RepoMount = "type=bind,source=$RepoRoot,target=/repo"

    & docker run --rm `
        --mount $RepoMount `
        --workdir /repo `
        $GitleaksImage git `
        --source /repo `
        --config /repo/$ConfigPath `
        --redact `
        --report-format json `
        --report-path /repo/$ReportDir/gitleaks.json `
        --exit-code 1

    $JsonExit = $LASTEXITCODE
    Assert-GitleaksExitCode -ExitCode $JsonExit -ReportKind "JSON"

    & docker run --rm `
        --mount $RepoMount `
        --workdir /repo `
        $GitleaksImage git `
        --source /repo `
        --config /repo/$ConfigPath `
        --redact `
        --report-format junit `
        --report-path /repo/$ReportDir/gitleaks-junit.xml `
        --exit-code 1

    $JunitExit = $LASTEXITCODE
    Assert-GitleaksExitCode -ExitCode $JunitExit -ReportKind "JUnit"
}

if ($JsonExit -ne 0 -or $JunitExit -ne 0) {
    throw "Gitleaks found one or more findings. Review reports in $ResolvedReportDir."
}

Write-Host "Gitleaks scan completed with no findings."
Write-Host "Reports: $ResolvedReportDir"
