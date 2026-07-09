# Secure Delivery API

This deliberately small Spring Boot service is the workload used to exercise the DevSecOps platform.

## Responsibilities

- Provide a versioned status endpoint
- Provide health information for container orchestration
- Produce unit and web-layer test evidence
- Package as one executable JAR

Business features are intentionally limited so secure delivery remains the focus of the repository.

## Requirements

- Java 21
- Maven 3.6.3 or later
- Docker Desktop, if using the containerized verification path

## Local verification

From this directory:

```text
mvn clean verify
```

The command compiles the application, runs tests, and generates a JaCoCo coverage report.

## Containerized verification

From the repository root:

```powershell
.\scripts\verify-app.ps1
```

If PowerShell blocks local scripts on your workstation, use a process-level bypass:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\verify-app.ps1
```

This runs Maven inside the official `maven:3.9.16-eclipse-temurin-21` container image.

The script copies source code into the container's Linux filesystem before running Maven. That design avoids unreliable build behavior caused by writing Java coverage output directly through a Windows/OneDrive bind mount.

## Endpoints

- `GET /api/v1/status` - public service identity and status
- `GET /actuator/health` - orchestration health endpoint
