# ADR-010: Use Semgrep for static application security testing

## Status

Accepted

## Context

The platform needs a source-code security scanner that can detect risky patterns before code is packaged into a container image.

## Decision

Use Semgrep as the SAST control.

Start with local repository-owned rules under:

```text
security/semgrep/semgrep.yml
```

The trusted Jenkins release pipeline runs Semgrep before dependency scanning and before Docker image build.

## Consequences

### Positive

- Security rules are versioned with the repository.
- The baseline scan does not depend on remote rule registry availability.
- Findings are archived as JSON and JUnit evidence.
- `ERROR` severity findings block release.

### Trade-offs

- Local rules provide a narrower starting point than broad managed rule packs.
- Rules require maintenance as the application grows.
- Semgrep findings still require engineering triage; static analysis can produce false positives.

## Security note

SAST does not replace code review, dependency scanning, container scanning, or runtime controls. It catches source-level patterns early in the delivery lifecycle.
