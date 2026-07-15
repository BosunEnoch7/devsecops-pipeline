# ADR-008: Use Jenkins for trusted release orchestration

## Status

Accepted

## Context

The platform needs a trusted release pipeline that can run deeper security controls, build and scan container images, push to Amazon ECR, require production approval, and deploy.

GitHub Actions already provides fast pull request validation, but PR workflows should not receive production credentials or release authority.

## Decision

Use Jenkins as the trusted release orchestrator.

The Jenkinsfile defines the trusted release flow, evidence model, security gates, ECR promotion, digest capture, and manual approval controls.

The release pipeline includes:

- Trusted source checkout
- Release context validation
- Linting and unit tests
- SonarQube quality gate
- Gitleaks secret scanning
- Semgrep SAST
- OWASP Dependency-Check
- Terraform validation and IaC scanning
- Docker image build
- Trivy container image scanning
- Artifact identity capture
- ECR push and digest capture
- Manual production approval
- Deployment readiness contract

## Consequences

### Positive

- Release operations are separated from lower-trust PR validation.
- Jenkins can run controlled agents with approved security tooling.
- Release evidence is archived consistently.
- Manual approval is part of the delivery flow from the beginning.

### Trade-offs

- Jenkins requires operational care: plugins, credentials, backups, patching, and agent management.
- Some checks may be repeated from GitHub Actions to preserve independent release evidence.
- Jenkins requires supporting server configuration such as credentials, plugins, SonarQube webhook setup, and AWS/ECR access.

## Security note

Production credentials must be scoped to trusted Jenkins release jobs. They must not be exposed to pull request workflows.
