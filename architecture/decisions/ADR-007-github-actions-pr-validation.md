# ADR-007: Use GitHub Actions for pull request validation

## Status

Accepted

## Context

The platform needs a fast CI layer that gives developers feedback before code reaches the trusted release pipeline. This layer should validate the Java application without receiving production secrets or deployment authority.

## Decision

Use GitHub Actions for pull request and `main` branch validation.

The initial workflow will:

- Run on pull requests targeting `main`.
- Run on pushes to `main`.
- Support manual execution through `workflow_dispatch`.
- Use Java 21 with Eclipse Temurin.
- Cache Maven dependencies.
- Run `mvn --batch-mode clean verify`.
- Upload test and coverage evidence.
- Restrict `GITHUB_TOKEN` permissions to `contents: read`.

## Consequences

### Positive

- Developers receive fast feedback inside GitHub.
- Build and test evidence is attached to workflow runs.
- The workflow can later support branch protection rules.
- PR validation runs without AWS credentials or production secrets.

### Trade-offs

- GitHub Actions does not perform the trusted release in this design.
- Some validation is duplicated later in Jenkins to preserve independent release evidence.
- Artifact retention is intentionally short to reduce storage usage.

## Security note

PR workflows can run code that has not yet been trusted. They must not receive production deployment credentials.
