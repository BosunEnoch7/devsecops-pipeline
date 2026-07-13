# Troubleshooting Guide

This guide captures real issues discovered while building and verifying the platform.

## Docker Desktop is installed but the Docker engine is not running

### Symptom

Running a Docker command fails even though the `docker` CLI exists.

### Likely cause

Docker Desktop is installed, but the Linux engine has not started yet.

### Fix

Start Docker Desktop and wait until `docker version` shows both client and server information.

## PowerShell blocks the verification script

### Symptom

Running the script directly fails with a message similar to:

```text
running scripts is disabled on this system
```

### Likely cause

The workstation's PowerShell execution policy blocks local scripts.

### Fix

Use a process-level execution-policy bypass for this one command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\verify-app.ps1
```

This does not permanently change the machine policy.

## Maven build appears to hang on Windows or OneDrive-backed folders

### Symptom

The Maven test phase completes, but the container does not exit cleanly. Test reports may show success, while the process appears stuck during shutdown.

### Likely cause

The application workspace is mounted from a Windows OneDrive path. JaCoCo writes coverage data during JVM shutdown, and writing that file directly through a synced bind mount can be unreliable.

### Fix

Use the repository verification script:

```powershell
.\scripts\verify-app.ps1
```

The script mounts the application source as read-only, copies it into the container's Linux filesystem, and then runs:

```text
mvn --batch-mode clean verify
```

This gives us a cleaner CI-style signal because build output is written inside the container instead of through the host sync layer.

## Mockito dynamic agent warning during tests

### Symptom

Tests pass, but Maven prints a warning about Mockito self-attaching a Java agent.

### Meaning

This is not a current test failure. It is a forward-compatibility warning from the Java runtime and test tooling.

### Engineering decision

For now, we record the warning and continue. Later, when we harden the build pipeline, we can configure Mockito's recommended agent setup explicitly if the warning becomes a build policy concern.

## Docker cannot pull base images from Docker Hub

### Symptom

Docker build fails while loading metadata for an image such as:

```text
eclipse-temurin:21-jre-jammy
```

The error may mention DNS resolution for:

```text
registry-1.docker.io
```

### Likely cause

Docker Desktop cannot resolve or reach Docker Hub from its Linux VM/network path. This is usually a workstation DNS, proxy, VPN, or internet connectivity issue.

### Fix

Confirm Docker can pull the runtime image:

```powershell
docker pull eclipse-temurin:21-jre-jammy
```

If Docker Hub is temporarily unreachable but the Maven builder image is already cached, you can verify Dockerfile mechanics with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-app-image.ps1 -RuntimeImage maven:3.9.16-eclipse-temurin-21 -ImageTag offline-test
```

Do not treat the offline fallback as the production image. It is larger and includes build tooling.

## Gitleaks container image cannot be pulled

### Symptom

Running the local Gitleaks helper fails while pulling:

```text
ghcr.io/gitleaks/gitleaks:latest
```

The error may mention a TLS handshake timeout or registry connectivity failure.

### Likely cause

Docker Desktop cannot reach GitHub Container Registry from its Linux VM/network path.

### Fix

Option 1: retry when registry/network access is stable.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-gitleaks.ps1
```

Option 2: install the Gitleaks binary locally or on the Jenkins agent, then rerun the script. The helper prefers a native `gitleaks` binary when available.

### Important distinction

A scanner execution failure is not the same thing as a secret finding.

The pipeline should fail closed in both cases, but the incident response is different:

- Secret finding: rotate/revoke and investigate exposure.
- Scanner failure: fix the scanner/runtime environment and rerun.

## Semgrep container image cannot be pulled

### Symptom

Running the local Semgrep helper fails while pulling:

```text
semgrep/semgrep:latest
```

### Likely cause

Docker Desktop cannot reach the container registry from its Linux VM/network path.

### Fix

Option 1: retry when registry/network access is stable.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-semgrep.ps1
```

Option 2: install the Semgrep binary locally or on the Jenkins agent, then rerun the helper. The script prefers a native `semgrep` binary when available.

### Important distinction

A Semgrep execution failure is not the same thing as a SAST finding.

The pipeline should fail closed in both cases, but the response is different:

- SAST finding: triage and fix or document an approved exception.
- Scanner failure: fix the scanner/runtime environment and rerun.

## Dependency-Check first run is slow or fails downloading vulnerability data

### Symptom

The Dependency-Check stage takes a long time or fails while updating vulnerability data.

### Likely cause

Dependency-Check needs vulnerability data before it can produce accurate results. The first run may be slow, and restricted networks can prevent updates.

If no NVD API key is configured, Dependency-Check warns that updates can take a very long time.

### Fix

Confirm the Jenkins agent or local Docker/Maven environment can reach required vulnerability data sources. Then rerun:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-dependency-check.ps1
```

For Jenkins, create a secret text credential named:

```text
nvd-api-key
```

For local runs, pass an API key if available:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-dependency-check.ps1 -NvdApiKey "<your-key>"
```

### Important distinction

A Dependency-Check execution/update failure is not the same thing as a dependency vulnerability.

The release pipeline should fail closed in both cases, but the response is different:

- Vulnerability finding: upgrade, remove, replace, or document an approved exception.
- Scanner/update failure: fix network/cache/tooling and rerun.

## Jenkins waits forever for SonarQube quality gate

### Symptom

Jenkins submits SonarQube analysis but does not receive a quality gate result.

### Likely cause

The SonarQube webhook is missing or points to the wrong Jenkins URL.

### Fix

Configure a SonarQube webhook:

```text
<jenkins-url>/sonarqube-webhook/
```

Also confirm Jenkins has a SonarQube server configured with this exact name:

```text
sonarqube
```

The Jenkinsfile uses that name in:

```text
withSonarQubeEnv('sonarqube')
```

## Trivy first run is slow or cannot download vulnerability database

### Symptom

The Trivy scan takes a long time or fails before producing reports.

### Likely cause

Trivy needs to download or update its vulnerability database. Restricted networks, registry outages, or proxy issues can block the update.

### Fix

Confirm the local machine or Jenkins agent can reach the Trivy database registry, then rerun:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-trivy-image-scan.ps1 -Image secure-delivery-api:offline-test
```

If the Java vulnerability database is too slow for local validation, validate the OS-package path only:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-trivy-image-scan.ps1 -Image secure-delivery-api:offline-test -PackageTypes os
```

Do not treat OS-only local validation as the full Jenkins policy. Jenkins should scan both OS and language packages.

### Important distinction

A Trivy execution/database failure is not the same thing as a container vulnerability finding.

The pipeline should fail closed in both cases, but the response is different:

- Vulnerability finding: patch the base image/package or document an approved exception.
- Scanner failure: fix network/cache/tooling and rerun.

## Terraform validate fails in CI because backend credentials are missing

### Symptom

Terraform validation fails while trying to initialize the remote backend.

### Likely cause

The validation job is attempting to initialize the real backend instead of validating syntax/module structure only.

### Fix

For validation-only jobs, use:

```text
terraform init -backend=false
```

This is what the repository validation script and Jenkinsfile use.

Remote backend access should be required only for plan/apply workflows in trusted deployment stages.

## Container starts but the first HTTP request fails

### Symptom

The container is running, but the first request to `/api/v1/status` or `/actuator/health` fails.

### Likely cause

The request raced Spring Boot startup. On Docker Desktop, host-to-container requests may also be slow immediately after startup.

### Fix

Check logs:

```powershell
docker logs devsecops-api-phase7
```

Wait until the logs show Tomcat started, then retry:

```powershell
Invoke-RestMethod -Uri http://127.0.0.1:18080/actuator/health
```

For automated validation, use:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\verify-app-container.ps1 -Image secure-delivery-api:offline-test
```
