# Security Gate Policy

## Purpose

This policy defines which findings stop delivery, which require review, and which may be tracked for later remediation. Scanner output alone is evidence; policy determines the pipeline outcome.

## Gate outcomes

| Outcome | Meaning | Pipeline behavior |
|---|---|---|
| Pass | Required control completed within policy | Continue |
| Warn | Risk requires tracking but does not currently exceed the blocking threshold | Continue and create remediation evidence |
| Block | Control failed or risk exceeds the accepted threshold | Stop before artifact promotion |

An unavailable required scanner is not a pass. Release jobs fail closed unless an authorized, documented emergency procedure applies.

## Pull-request gates

Pull-request checks run against untrusted proposed changes and must not receive production credentials.

| Control | Tool | Blocking condition |
|---|---|---|
| Formatting and linting | Language-specific tooling | Any configured lint failure |
| Unit tests | Test framework | Any failed test |
| Secret detection | Gitleaks | Any unapproved probable secret |
| Static security analysis | Semgrep | Error-severity finding or configured blocking rule |
| Terraform formatting and validation | Terraform | Formatting, initialization, or validation failure |
| IaC security | Trivy | Critical or high misconfiguration |

## Trusted release gates

Release checks run after merge to the protected branch.

| Control | Tool | Blocking condition |
|---|---|---|
| Source checkout validation | Jenkins | Repository, branch, or commit does not match the trusted event |
| Lint and unit tests | Project tooling | Any configured failure |
| Code quality | SonarQube | Quality gate fails or cannot be retrieved |
| Secret detection | Gitleaks | Any unapproved probable secret in configured scope |
| Static security analysis | Semgrep | Error-severity finding or configured blocking rule |
| Dependency analysis | OWASP Dependency-Check | Critical or high finding without an active exception |
| Docker build | Docker builder | Build failure or required hardening check failure |
| Container analysis | Trivy | Critical or high fixable vulnerability without an active exception |
| IaC validation | Terraform and Trivy | Validation failure or critical/high misconfiguration |
| Artifact identity | ECR/Jenkins metadata | Digest missing or inconsistent |
| Production approval | Jenkins | Approval absent, expired, or references another digest |
| Post-deployment verification | Health and smoke checks | Required verification fails |

## Severity is not the only input

Severity is a starting point, not a complete risk decision. Triage also considers:

- Whether the vulnerable component is present in the final artifact
- Whether the vulnerable path is reachable
- Whether a vendor fix exists
- Whether exploitation is known or likely
- Whether the workload is internet-facing
- Existing compensating controls
- The confidence of the scanner match

Only a documented exception can override a blocking result.

## Baseline policy

Existing findings discovered when a control is introduced may be placed in a time-bound baseline. New findings must not be silently added to that baseline.

This allows incremental adoption without allowing the security posture to deteriorate.

## Scanner failure policy

- Pull-request jobs may retry a transient scanner failure once.
- Trusted release jobs fail closed when required evidence cannot be produced.
- A scanner outage is recorded distinctly from a vulnerability finding.
- Bypassing a required scanner needs an emergency exception and retrospective review.

## Evidence retention

Each release should retain or link to:

- Commit SHA
- Jenkins build identifier
- Scanner names and versions
- Quality-gate outcome
- Sanitized reports or report locations
- Image tag and digest
- Exception identifiers
- Approver identity and approval time
- Deployment and smoke-test result

Reports must not expose secrets or sensitive infrastructure details.

