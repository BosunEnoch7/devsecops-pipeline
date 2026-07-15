# Deployment Guide

## Current deployment status

The platform now supports pushing a verified image to Amazon ECR and capturing the immutable image digest.

Actual runtime deployment will be wired in a later phase.

## ECR promotion

Jenkins pushes the verified image to ECR after:

1. Tests pass.
2. SonarQube quality gate passes.
3. Gitleaks passes.
4. Semgrep passes.
5. Dependency-Check passes.
6. Terraform/IaC validation passes.
7. Docker image build succeeds.
8. Trivy image scan passes.

The ECR stage writes evidence to:

```text
evidence/ecr/
```

The most important file is:

```text
image-uri-with-digest.txt
```

Deployment should use that digest-based URI, not a mutable tag alone.

## Manual approval

Jenkins displays the digest-based image URI during manual approval.

Approval is blocked if the digest is missing or malformed.

Approval evidence is written to:

```text
evidence/production-approval.txt
evidence/approved-image-uri.txt
```

## Runtime deployment contract

See:

```text
docs/deployment/runtime-deployment-contract.md
```

The current Jenkins deployment stage records the approved digest and marks runtime deployment as deferred until ECS infrastructure is implemented.

See:

```text
docs/deployment/ecr-promotion-guide.md
```
