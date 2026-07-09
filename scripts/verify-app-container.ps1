<#
.SYNOPSIS
Verifies that the Secure Delivery API container starts correctly and runs as non-root.

.DESCRIPTION
This script starts a temporary container, checks the runtime user, waits for the
Spring Boot health endpoint, checks the public status endpoint, and then stops
the temporary container.
#>

[CmdletBinding()]
param(
    [string]$Image = "secure-delivery-api:local",
    [int]$HostPort = 18080
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker CLI was not found. Install Docker Desktop or ensure docker is on PATH."
}

docker version | Out-Null

$ContainerName = "devsecops-api-validation-$PID"
$BaseUri = "http://127.0.0.1:$HostPort"

try {
    & docker run --rm -d --name $ContainerName -p "${HostPort}:8080" $Image | Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to start validation container."
    }

    $Identity = & docker exec $ContainerName id

    if ($Identity -notmatch "uid=10001") {
        throw "Container is not running as expected non-root UID 10001. Actual identity: $Identity"
    }

    $Health = $null

    for ($Attempt = 1; $Attempt -le 30; $Attempt++) {
        try {
            $Health = Invoke-RestMethod -Uri "$BaseUri/actuator/health" -TimeoutSec 5

            if ($Health.status -eq "UP") {
                break
            }
        }
        catch {
            Start-Sleep -Seconds 2
        }
    }

    if ($null -eq $Health -or $Health.status -ne "UP") {
        throw "Health endpoint did not become UP."
    }

    $Status = Invoke-RestMethod -Uri "$BaseUri/api/v1/status" -TimeoutSec 10

    if ($Status.service -ne "secure-delivery-api" -or $Status.status -ne "UP") {
        throw "Status endpoint returned an unexpected response."
    }

    Write-Host "Container identity: $Identity"
    Write-Host "Health endpoint: $($Health.status)"
    Write-Host "Status endpoint: $($Status.service) $($Status.status)"
}
finally {
    & docker stop $ContainerName | Out-Null
}
