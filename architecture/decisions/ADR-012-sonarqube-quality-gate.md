# ADR-012: Use SonarQube for code quality gates

## Status

Accepted

## Context

The platform needs a code-health gate that evaluates quality, maintainability, reliability, security hotspots, duplication, and coverage. Security scanners alone do not provide a full quality signal.

## Decision

Use SonarQube with the SonarScanner for Maven.

The Jenkins release pipeline runs SonarQube analysis after tests and waits for the SonarQube quality gate before continuing.

The scanner plugin version is pinned to:

```text
5.5.0.6356
```

## Consequences

### Positive

- Quality gate status becomes a release control.
- JaCoCo coverage is imported into SonarQube.
- Jenkins can fail the release when the gate fails.
- Code-health evidence is captured before artifact promotion.

### Trade-offs

- SonarQube requires server operations, tokens, project setup, and webhook configuration.
- A quality gate is only as good as the policy configured in SonarQube.
- The pipeline cannot fully validate the gate without a running SonarQube server and webhook.

## Security note

SonarQube tokens must be stored in Jenkins or SonarQube integration configuration. They must not be committed to Git or printed in logs.
