<#
.SYNOPSIS
Tags a local Docker image, pushes it to Amazon ECR, and captures the immutable digest.

.DESCRIPTION
This helper assumes AWS credentials are already available through the environment,
AWS SSO, an assumed role, or a configured AWS profile.

It does not create the ECR repository. Repository creation belongs to Terraform.
#>

[CmdletBinding()]
param(
    [string]$Image = "secure-delivery-api:offline-test",
    [string]$AwsRegion = "us-east-1",
    [string]$EcrRepository = "secure-delivery-api",
    [string]$ImageTag = "local",
    [string]$ReportDir = ".build/ecr"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ResolvedReportDir = Join-Path $RepoRoot $ReportDir

New-Item -ItemType Directory -Force -Path $ResolvedReportDir | Out-Null

if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    throw "AWS CLI was not found. Install AWS CLI v2 and authenticate before pushing to ECR."
}

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker CLI was not found. Install Docker Desktop or ensure docker is on PATH."
}

docker version | Out-Null

if ($LASTEXITCODE -ne 0) {
    throw "Docker is not available. Start Docker Desktop before pushing to ECR."
}

docker image inspect $Image | Out-Null

if ($LASTEXITCODE -ne 0) {
    throw "Local image '$Image' does not exist. Build it before pushing."
}

$AccountId = aws sts get-caller-identity --query Account --output text

if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($AccountId)) {
    throw "Unable to determine AWS account ID. Check AWS authentication."
}

aws ecr describe-repositories --region $AwsRegion --repository-names $EcrRepository | Out-Null

if ($LASTEXITCODE -ne 0) {
    throw "ECR repository '$EcrRepository' was not found in region '$AwsRegion'. Create it with Terraform before pushing."
}

$Registry = "$AccountId.dkr.ecr.$AwsRegion.amazonaws.com"
$RemoteImage = "$Registry/$EcrRepository`:$ImageTag"

aws ecr get-login-password --region $AwsRegion | docker login --username AWS --password-stdin $Registry

if ($LASTEXITCODE -ne 0) {
    throw "Docker login to ECR failed."
}

docker tag $Image $RemoteImage
docker push $RemoteImage

if ($LASTEXITCODE -ne 0) {
    throw "Docker push to ECR failed."
}

$Digest = aws ecr describe-images `
    --region $AwsRegion `
    --repository-name $EcrRepository `
    --image-ids "imageTag=$ImageTag" `
    --query "imageDetails[0].imageDigest" `
    --output text

if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($Digest) -or $Digest -eq "None") {
    throw "Unable to capture ECR image digest for '$RemoteImage'."
}

$RemoteImage | Out-File -Encoding utf8 (Join-Path $ResolvedReportDir "remote-image-tag.txt")
$Digest | Out-File -Encoding utf8 (Join-Path $ResolvedReportDir "image-digest.txt")
"$Registry/$EcrRepository@$Digest" | Out-File -Encoding utf8 (Join-Path $ResolvedReportDir "image-uri-with-digest.txt")

Write-Host "Pushed image: $RemoteImage"
Write-Host "Digest: $Digest"
