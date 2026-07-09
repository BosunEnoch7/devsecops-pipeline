<#
.SYNOPSIS
Runs SonarQube analysis for the Secure Delivery API.

.DESCRIPTION
This helper runs Maven tests first so compiled classes and JaCoCo coverage exist,
then runs the pinned SonarScanner for Maven plugin.

The script prefers local Maven. If Maven is unavailable, it runs inside the
official Maven container image.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SonarHostUrl,

    [Parameter(Mandatory = $true)]
    [string]$SonarToken,

    [string]$ScannerVersion = "5.5.0.6356",
    [string]$MavenImage = "maven:3.9.16-eclipse-temurin-21",
    [string]$MavenCacheVolume = "devsecops-maven-cache"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$AppPath = Resolve-Path (Join-Path $RepoRoot "app")

$MavenArgs = @(
    "--batch-mode",
    "clean",
    "verify",
    "org.sonarsource.scanner.maven:sonar-maven-plugin:${ScannerVersion}:sonar",
    "-Dsonar.host.url=$SonarHostUrl",
    "-Dsonar.token=$SonarToken"
)

$NativeMaven = Get-Command mvn -ErrorAction SilentlyContinue

if ($NativeMaven) {
    Push-Location $AppPath
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
        throw "Docker is not available to run SonarQube analysis. Start Docker Desktop or install Maven locally."
    }

    $RepoMount = "type=bind,source=$AppPath,target=/workspace"

    $DockerArgs = @(
        "run",
        "--rm",
        "--mount",
        $RepoMount,
        "--mount",
        "type=volume,source=$MavenCacheVolume,target=/root/.m2",
        "--workdir",
        "/workspace",
        $MavenImage,
        "mvn"
    ) + $MavenArgs

    & docker @DockerArgs
    $ScanExit = $LASTEXITCODE
}

if ($ScanExit -ne 0) {
    throw "SonarQube analysis failed with exit code $ScanExit."
}

Write-Host "SonarQube analysis completed successfully."
