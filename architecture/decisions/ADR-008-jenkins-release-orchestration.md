# ADR-008: Use Jenkins for trusted release orchestration

## Status

Accepted

## Context

The platform needs a trusted release pipeline that can run deeper security controls, build and scan container images, push to Amazon ECR, require production approval, and deploy.

GitHub Actions already provides fast pull request validation, but PR workflows should not receive production credentials or release authority.

## Decision

Use Jenkins as the trusted release orchestrator.

The initial Jenkinsfile defines the release flow and evidence model, while scanner integrations are added in later phases.

The release pipeline includes:

- Trusted source checkout
- Release context validation
- Linting and unit tests
- SonarQube quality gate placeholder
- Gitleaks secret scanning placeholder
- Semgrep SAST placeholder
- OWASP Dependency-Check placeholder
- Terraform validation placeholder
- Docker image build
- Trivy container scan placeholder
- Artifact identity capture
- ECR push placeholder
- Manual production approval
- Deployment placeholder

## Consequences

### Positive

- Release operations are separated from lower-trust PR validation.
- Jenkins can run controlled agents with approved security tooling.
- Release evidence is archived consistently.
- Manual approval is part of the delivery flow from the beginning.

### Trade-offs

- Jenkins requires operational care: plugins, credentials, backups, patching, and agent management.
- Some checks may be repeated from GitHub Actions to preserve independent release evidence.
- The first Jenkinsfile contains placeholders until each tool is integrated and tested.

## Security note

Production credentials must be scoped to trusted Jenkins release jobs. They must not be exposed to pull request workflows.
