<#
.SYNOPSIS
Runs the Secure Delivery API verification build inside a controlled Maven container.

.DESCRIPTION
This script intentionally copies the application source from the host bind mount
into the container's Linux filesystem before running Maven.

Why:
- The host workspace may live in OneDrive or another synced Windows directory.
- Java coverage tools such as JaCoCo write files during JVM shutdown.
- Writing those files directly through a Windows bind mount can be slow or flaky.

The build still uses the local source code, but Maven writes build output inside
the container. This gives us a cleaner signal for CI-style verification.
#>

[CmdletBinding()]
param(
    [string]$MavenImage = "maven:3.9.16-eclipse-temurin-21",
    [string]$MavenCacheVolume = "devsecops-maven-cache"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$AppPath = Resolve-Path (Join-Path $RepoRoot "app")

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker CLI was not found. Install Docker Desktop or ensure docker is on PATH."
}

docker version | Out-Null

$DockerArgs = @(
    "run",
    "--rm",
    "--mount",
    "type=bind,source=$AppPath,target=/source,readonly",
    "--mount",
    "type=volume,source=$MavenCacheVolume,target=/root/.m2",
    "--workdir",
    "/workspace",
    $MavenImage,
    "sh",
    "-c",
    "tar --exclude=target -C /source -cf - . | tar -C /workspace -xf - && mvn --batch-mode clean verify"
)

& docker @DockerArgs

if ($LASTEXITCODE -ne 0) {
    throw "Application verification failed with exit code $LASTEXITCODE."
}
