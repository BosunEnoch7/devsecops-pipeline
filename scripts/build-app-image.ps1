<#
.SYNOPSIS
Builds the Secure Delivery API container image.

.DESCRIPTION
The Docker build must be run from the repository root so the Dockerfile can copy
only the required application files from the build context.
#>

[CmdletBinding()]
param(
    [string]$ImageName = "secure-delivery-api",
    [string]$ImageTag = "local",
    [string]$BuilderImage = "maven:3.9.16-eclipse-temurin-21",
    [string]$RuntimeImage = "eclipse-temurin:21-jre-jammy",
    [string]$BuildVersion = "0.1.0",
    [string]$VcsRef = "local",
    [string]$BuildDate = "unknown"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$Dockerfile = Join-Path $RepoRoot "docker/app/Dockerfile"
$Image = "${ImageName}:${ImageTag}"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker CLI was not found. Install Docker Desktop or ensure docker is on PATH."
}

docker version | Out-Null

$DockerArgs = @(
    "build",
    "--progress",
    "plain",
    "--file",
    $Dockerfile,
    "--tag",
    $Image,
    "--build-arg",
    "BUILDER_IMAGE=$BuilderImage",
    "--build-arg",
    "RUNTIME_IMAGE=$RuntimeImage",
    "--build-arg",
    "BUILD_VERSION=$BuildVersion",
    "--build-arg",
    "VCS_REF=$VcsRef",
    "--build-arg",
    "BUILD_DATE=$BuildDate",
    $RepoRoot
)

& docker @DockerArgs

if ($LASTEXITCODE -ne 0) {
    throw "Docker image build failed with exit code $LASTEXITCODE."
}

Write-Host "Built image: $Image"
