# devsecops-pipeline

Enterprise-inspired DevSecOps platform demonstrating secure, traceable software delivery from GitHub to Jenkins, security gates, Docker, Amazon ECR, manual approval, and deployment readiness.

Built by **Olatubosun Enoch David** as a flagship DevSecOps portfolio project.

## What this project demonstrates

- Secure CI/CD design
- GitHub Actions PR validation
- Jenkins trusted release orchestration
- Java/Spring Boot sample workload
- Docker image hardening
- SonarQube quality gate
- Gitleaks secret scanning
- Semgrep SAST
- OWASP Dependency-Check
- Trivy image and IaC scanning
- Terraform validation
- Amazon ECR image promotion
- Digest-based release approval
- Production-style documentation and evidence

## Delivery flow

```text
Developer
  -> GitHub
  -> GitHub Actions PR validation
  -> Jenkins trusted release pipeline
  -> Build and unit tests
  -> SonarQube quality gate
  -> Gitleaks secret scanning
  -> Semgrep SAST
  -> OWASP Dependency-Check
  -> Terraform validation and IaC scan
  -> Docker build
  -> Trivy image scan
  -> Amazon ECR push
  -> Digest capture
  -> Manual production approval
  -> Deployment readiness
```

## Current status

The project now includes the core secure delivery platform and documentation framework.

Runtime deployment is intentionally deferred until ECS infrastructure is added. The pipeline already promotes a verified image to ECR and records the digest that future deployment should consume.

## Repository structure

```text
devsecops-pipeline/
  .github/workflows/        GitHub Actions PR validation
  app/                      Spring Boot sample service
  architecture/             Architecture, threat model, ADRs
  docker/                   Hardened application Dockerfile
  docs/                     Deployment, security, operations, and project docs
  jenkins/                  Jenkins release pipeline documentation
  scripts/                  Local verification and scanner helpers
  security/                 Scanner config and security policies
  terraform/                Terraform validation and environment structure
```

## Quick local checks

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\verify-app.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-app-image.ps1 -RuntimeImage maven:3.9.16-eclipse-temurin-21 -ImageTag offline-test
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\verify-app-container.ps1 -Image secure-delivery-api:offline-test
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-semgrep.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate-terraform.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-iac-scan.ps1
```

Some scanners require network access to vulnerability databases. See the troubleshooting guide if first runs are slow.

## Key documentation

- [Architecture overview](architecture/system-overview.md)
- [Threat model](architecture/threat-model.md)
- [Security gate policy](security/policies/security-gates.md)
- [Jenkins release stages](jenkins/release-pipeline-stages.md)
- [Deployment guide](docs/deployment/deployment-guide.md)
- [ECR promotion guide](docs/deployment/ecr-promotion-guide.md)
- [Security guide](docs/security/security-guide.md)
- [Troubleshooting guide](docs/operations/troubleshooting-guide.md)
- [Evidence guide](docs/project/evidence-guide.md)
- [Screenshots checklist](docs/project/screenshots-checklist.md)
- [Lessons learned](docs/project/lessons-learned.md)

## Evidence pack

The [`screenshots`](screenshots) folder contains the evidence plan for proving the pipeline ran end to end.

Recommended proof points include:

- Jenkins release pipeline stage view
- SonarQube quality gate
- Gitleaks, Semgrep, Dependency-Check, and Trivy results
- Terraform validation and IaC scan results
- Amazon ECR pushed image and immutable digest
- Manual production approval by digest
- Application health check

See the [evidence guide](docs/project/evidence-guide.md) before adding screenshots.

## Security philosophy

This project treats security as evidence-driven delivery:

- Every major release decision should produce evidence.
- Pull request jobs should not receive production credentials.
- Trusted release jobs fail closed when required controls cannot run.
- Secrets are rotated, not merely deleted.
- Artifacts are approved and deployed by digest, not mutable tags.

## Next improvements

- Add ECS runtime infrastructure.
- Deploy approved digest to ECS.
- Add post-deployment smoke checks.
- Add OIDC-based AWS authentication.
- Add SBOM generation and signing.
