# Scanner Responsibilities

## Why responsibilities are separated

Multiple tools may detect the same issue, but each has a primary purpose. Clear ownership prevents contradictory thresholds and meaningless duplicated work.

| Tool | Primary responsibility | Not a replacement for |
|---|---|---|
| SonarQube | Code quality, maintainability, quality gate, selected code-security analysis | Dedicated secret, dependency, or image scanning |
| Semgrep | Source-aware static application security rules | Dependency and final-artifact analysis |
| Gitleaks | Secret pattern detection in source and history | Credential rotation or provider audit |
| OWASP Dependency-Check | Known vulnerabilities in application dependencies | Final container and OS package scanning |
| Trivy | Container vulnerability analysis and Terraform/Docker misconfiguration checks | Source-specific SAST and quality governance |
| Terraform CLI | Formatting, syntax, provider, and plan validation | Security analysis or proof of safe infrastructure |

## Duplication policy

A check may run in both GitHub Actions and Jenkins when it protects a different trust boundary:

- GitHub Actions gives early feedback before merge.
- Jenkins independently verifies trusted release input.

Duplicate execution must have a stated purpose. Different configurations that create conflicting results should be corrected rather than normalized.

