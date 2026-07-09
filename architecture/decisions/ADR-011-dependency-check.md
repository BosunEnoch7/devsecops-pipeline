# ADR-011: Use OWASP Dependency-Check for Java dependency scanning

## Status

Accepted

## Context

The application depends on third-party Java libraries. Vulnerabilities can enter the system through direct or transitive dependencies even when the application code is clean.

## Decision

Use OWASP Dependency-Check through the Maven plugin.

The trusted Jenkins release pipeline runs Dependency-Check after SAST and before Docker image build.

The scan produces:

- HTML report
- XML report
- JSON report
- JUnit report

The initial blocking threshold is CVSS `7.0`.

## Consequences

### Positive

- Java dependency analysis integrates naturally with Maven.
- Reports can be archived as release evidence.
- JUnit output can surface vulnerability findings in Jenkins.
- High and critical dependency vulnerabilities block release.

### Trade-offs

- The first scan may be slow because vulnerability data must be downloaded and processed.
- Dependency-Check may produce false positives that require careful suppression handling.
- CVSS alone is not a full risk decision; reachability and exploitability still need human triage.

## Security note

Suppressions must be narrow, owned, and time-bound. A suppression is not a fix.
