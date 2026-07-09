# SonarQube Guide

SonarQube is the platform's code quality and quality-gate control.

It complements the security scanners:

- Gitleaks finds committed secrets.
- Semgrep finds insecure code patterns.
- Dependency-Check finds vulnerable dependencies.
- SonarQube evaluates broader code health and quality gate status.

## Project configuration

Maven properties live in:

```text
app/pom.xml
```

Reference properties are also documented in:

```text
app/sonar-project.properties
```

The project key is:

```text
devsecops-pipeline_secure-delivery-api
```

## Coverage

The Java build generates JaCoCo XML coverage at:

```text
app/target/site/jacoco/jacoco.xml
```

SonarQube imports this coverage during analysis.

## Jenkins integration

Jenkins must be configured with a SonarQube server installation named:

```text
sonarqube
```

The Jenkinsfile uses:

```text
withSonarQubeEnv('sonarqube')
waitForQualityGate()
```

The quality gate requires a SonarQube webhook pointing to Jenkins:

```text
<jenkins-url>/sonarqube-webhook/
```

Without the webhook, Jenkins may submit analysis but never receive the quality gate result.

## What the quality gate means

A quality gate is a release decision based on code-health policy.

It can include conditions such as:

- New bugs
- New vulnerabilities
- Security hotspots requiring review
- Coverage on new code
- Duplicated lines
- Maintainability rating
- Reliability rating

The exact gate is configured in SonarQube. The pipeline treats a failed or unavailable gate as a release blocker.

## Local usage

From the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-sonarqube.ps1 -SonarHostUrl "http://localhost:9000" -SonarToken "<token>"
```

Do not commit SonarQube tokens. Use local environment handling, Jenkins credentials, or the Jenkins SonarQube server configuration.
