# ADR-009: Use Gitleaks for secret scanning

## Status

Accepted

## Context

Secrets committed to Git can lead to cloud account compromise, supply-chain attacks, and production incidents. Secret detection must happen before artifact build and promotion.

## Decision

Use Gitleaks for secret scanning.

The trusted Jenkins release pipeline runs:

```text
gitleaks git --source .
```

Reports are generated in JSON and JUnit formats with redaction enabled.

## Consequences

### Positive

- The release pipeline blocks probable committed secrets.
- Secret scan evidence is archived with the Jenkins build.
- JUnit output makes findings visible in Jenkins test reporting.
- Redaction reduces the risk of storing raw secrets in CI artifacts.

### Trade-offs

- Secret scanners can produce false positives.
- Allowlisting requires discipline; broad allowlists can hide real leaks.
- A clean scan does not prove no secret exists anywhere. It proves the configured scanner found no matching secret patterns.

## Security note

If a real secret is found, deletion is not enough. The secret must be revoked or rotated.
