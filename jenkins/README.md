# Jenkins

Jenkins is the trusted release orchestrator for this DevSecOps platform.

The root pipeline file is:

```text
Jenkinsfile
```

## Why Jenkins is used here

GitHub Actions handles fast pull request validation. Jenkins handles release orchestration after code reaches the trusted path.

This gives us a useful separation:

- GitHub Actions: fast feedback, no production secrets, low trust.
- Jenkins: controlled agents, security tooling, release evidence, ECR push, production approval, deployment.

## Current phase

Phase 9 creates the Jenkins release pipeline foundation.

Some stages intentionally contain `PENDING` evidence files. This is not forgotten work. It is a deliberate phased buildout so each DevSecOps control can be added, tested, and explained separately.

## Expected Jenkins agent capabilities

The Jenkins agent that runs this pipeline should eventually have:

- Git
- Java 21
- Maven
- Docker CLI and access to a Docker daemon or builder
- SonarQube scanner
- Gitleaks
- Semgrep
- OWASP Dependency-Check
- Trivy
- Terraform
- AWS CLI

We will introduce and validate these tools one phase at a time.

Gitleaks, Semgrep, Maven-based OWASP Dependency-Check, and Trivy are now required release tools. If any required tool is missing from the Jenkins agent, the related stage must fail rather than silently pass.

Dependency-Check expects this Jenkins secret text credential:

```text
nvd-api-key
```

## Expected Jenkins plugins

The current Jenkinsfile uses common Pipeline features and expects these Jenkins capabilities/plugins:

- Pipeline
- Declarative Pipeline
- Git
- JUnit
- Credentials Binding, when credentialed stages are added later
- SonarQube Scanner for Jenkins
- AnsiColor, because the pipeline enables `ansiColor('xterm')`

If AnsiColor is not installed, either install the plugin or remove the `ansiColor('xterm')` option.

## SonarQube Jenkins configuration

Configure a SonarQube server in Jenkins with this exact name:

```text
sonarqube
```

The SonarQube server must send quality-gate webhooks to:

```text
<jenkins-url>/sonarqube-webhook/
```

## Evidence model

The pipeline writes release evidence under:

```text
evidence/
```

Jenkins archives this folder after every run.

Evidence will eventually include:

- Commit SHA
- Jenkins build metadata
- Test results
- Coverage reports
- Scanner reports
- Docker image ID
- ECR image digest
- Manual approver identity
- Deployment result

## Security boundary

Do not inject AWS production credentials into pull request jobs.

Jenkins credentials should be scoped tightly and used only in trusted release jobs.
