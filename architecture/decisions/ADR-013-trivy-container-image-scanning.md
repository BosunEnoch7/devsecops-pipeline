# ADR-013: Use Trivy for container image scanning

## Status

Accepted

## Context

The platform needs to inspect the final container image before promotion. Application dependency scanning alone does not cover operating system packages and runtime image contents.

## Decision

Use Trivy for container image vulnerability scanning.

The trusted Jenkins release pipeline runs Trivy after Docker image build and before artifact identity capture, ECR push, approval, or deployment.

The initial blocking policy is:

- `HIGH`
- `CRITICAL`
- fixed vulnerabilities only through `--ignore-unfixed`

Full JSON evidence is still archived for review.

## Consequences

### Positive

- The deployable image is scanned before promotion.
- OS and language package vulnerabilities are visible.
- JSON and table reports are retained as release evidence.
- Blocking is focused on high-impact actionable vulnerabilities.

### Trade-offs

- Trivy needs vulnerability database updates.
- First runs can be slow or fail in restricted networks.
- Ignoring unfixed vulnerabilities avoids impossible remediation but still requires risk review for serious issues.

## Security note

An image scan is not a substitute for using hardened base images, non-root containers, minimal packages, and digest-based promotion.
