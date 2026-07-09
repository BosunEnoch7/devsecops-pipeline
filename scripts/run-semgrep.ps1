<#
.SYNOPSIS
Runs Semgrep SAST scanning for the repository.

.DESCRIPTION
The script prefers a locally installed semgrep binary. If semgrep is not
available on PATH, it falls back to the official Semgrep container image.

Reports are written to .build/semgrep by default.
#>

[CmdletBinding()]
param(
    [string]$ConfigPath = "security/semgrep/semgrep.yml",
    [string]$ReportDir = ".build/semgrep",
    [string]$SemgrepImage = "semgrep/semgrep:latest",
    [string[]]$ScanPaths = @("app", "docker")
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ResolvedConfig = Resolve-Path (Join-Path $RepoRoot $ConfigPath)
$ResolvedReportDir = Join-Path $RepoRoot $ReportDir

New-Item -ItemType Directory -Force -Path $ResolvedReportDir | Out-Null

$JsonReport = Join-Path $ResolvedReportDir "semgrep.json"
$JunitReport = Join-Path $ResolvedReportDir "semgrep-junit.xml"
$NativeScanTargets = @()
$ContainerScanTargets = @()

foreach ($ScanPath in $ScanPaths) {
    $NativeScanTargets += (Join-Path $RepoRoot $ScanPath)
    $ContainerScanTargets += "/repo/$ScanPath"
}

function Assert-SemgrepExitCode {
    param(
        [int]$ExitCode,
        [string]$ReportKind
    )

    if ($ExitCode -ne 0 -and $ExitCode -ne 1) {
        throw "Semgrep $ReportKind scan failed to execute correctly. Exit code: $ExitCode."
    }
}

$NativeSemgrep = Get-Command semgrep -ErrorAction SilentlyContinue

if ($NativeSemgrep) {
    & semgrep scan `
        --config $ResolvedConfig `
        --metrics off `
        --error `
        --json `
        --json-output $JsonReport `
        $NativeScanTargets

    $JsonExit = $LASTEXITCODE
    Assert-SemgrepExitCode -ExitCode $JsonExit -ReportKind "JSON"

    & semgrep scan `
        --config $ResolvedConfig `
        --metrics off `
        --error `
        --junit-xml `
        --junit-xml-output $JunitReport `
        $NativeScanTargets

    $JunitExit = $LASTEXITCODE
    Assert-SemgrepExitCode -ExitCode $JunitExit -ReportKind "JUnit"
}
else {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        throw "Neither semgrep nor docker was found. Install Semgrep or Docker Desktop."
    }

    docker version | Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw "Docker is not available to run the Semgrep container. Start Docker Desktop or install Semgrep locally."
    }

    $RepoMount = "type=bind,source=$RepoRoot,target=/repo"

    & docker run --rm `
        --mount $RepoMount `
        --workdir /repo `
        $SemgrepImage semgrep scan `
        --config /repo/$ConfigPath `
        --metrics off `
        --error `
        --json `
        --json-output /repo/$ReportDir/semgrep.json `
        $ContainerScanTargets

    $JsonExit = $LASTEXITCODE
    Assert-SemgrepExitCode -ExitCode $JsonExit -ReportKind "JSON"

    & docker run --rm `
        --mount $RepoMount `
        --workdir /repo `
        $SemgrepImage semgrep scan `
        --config /repo/$ConfigPath `
        --metrics off `
        --error `
        --junit-xml `
        --junit-xml-output /repo/$ReportDir/semgrep-junit.xml `
        $ContainerScanTargets

    $JunitExit = $LASTEXITCODE
    Assert-SemgrepExitCode -ExitCode $JunitExit -ReportKind "JUnit"
}

if ($JsonExit -ne 0 -or $JunitExit -ne 0) {
    throw "Semgrep found one or more blocking findings. Review reports in $ResolvedReportDir."
}

Write-Host "Semgrep scan completed with no blocking findings."
Write-Host "Reports: $ResolvedReportDir"
