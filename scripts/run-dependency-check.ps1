<#
.SYNOPSIS
Runs OWASP Dependency-Check for the Java application.

.DESCRIPTION
The script prefers a locally installed Maven binary. If Maven is not available,
it runs Maven inside the official Maven container image.

Reports are written to .build/dependency-check by default.
#>

[CmdletBinding()]
param(
    [string]$PluginVersion = "12.1.0",
    [string]$ReportDir = ".build/dependency-check",
    [string]$SuppressionFile = "security/dependency-check/suppressions.xml",
    [string]$FailBuildOnCVSS = "7",
    [string]$NvdApiKey = "",
    [string]$MavenImage = "maven:3.9.16-eclipse-temurin-21",
    [string]$MavenCacheVolume = "devsecops-maven-cache"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ResolvedReportDir = Join-Path $RepoRoot $ReportDir

New-Item -ItemType Directory -Force -Path $ResolvedReportDir | Out-Null

$MavenArgs = @(
    "--batch-mode",
    "-f",
    "app/pom.xml",
    "org.owasp:dependency-check-maven:${PluginVersion}:check",
    "-Dformats=HTML,XML,JSON,JUNIT",
    "-DoutputDirectory=$ReportDir",
    "-DsuppressionFiles=$SuppressionFile",
    "-DfailBuildOnCVSS=$FailBuildOnCVSS",
    "-DskipTestScope=true"
)

if (-not [string]::IsNullOrWhiteSpace($NvdApiKey)) {
    $MavenArgs += "-DnvdApiKey=$NvdApiKey"
}

$NativeMaven = Get-Command mvn -ErrorAction SilentlyContinue

if ($NativeMaven) {
    Push-Location $RepoRoot
    try {
        & mvn @MavenArgs
        $ScanExit = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }
}
else {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        throw "Neither Maven nor Docker was found. Install Maven or Docker Desktop."
    }

    docker version | Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw "Docker is not available to run Dependency-Check. Start Docker Desktop or install Maven locally."
    }

    $RepoMount = "type=bind,source=$RepoRoot,target=/repo"

    $DockerArgs = @(
        "run",
        "--rm",
        "--mount",
        $RepoMount,
        "--mount",
        "type=volume,source=$MavenCacheVolume,target=/root/.m2",
        "--workdir",
        "/repo",
        $MavenImage,
        "mvn"
    ) + $MavenArgs

    & docker @DockerArgs
    $ScanExit = $LASTEXITCODE
}

if ($ScanExit -ne 0) {
    throw "Dependency-Check failed or found vulnerabilities at/above CVSS $FailBuildOnCVSS. Review reports in $ResolvedReportDir."
}

Write-Host "Dependency-Check completed successfully."
Write-Host "Reports: $ResolvedReportDir"
