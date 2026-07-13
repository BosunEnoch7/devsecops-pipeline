# Security Guide

## Implemented security controls

### Secret scanning

Gitleaks scans Git history for probable committed secrets. Any unapproved probable secret blocks the trusted release pipeline.

### Static application security testing

Semgrep scans source code and configuration for insecure patterns.

Configuration:

```text
security/semgrep/semgrep.yml
```

Local helper:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-semgrep.ps1
```

Jenkins reports:

```text
evidence/semgrep/
```

Blocking rule:

- `ERROR` severity Semgrep findings block release.

The initial Semgrep baseline uses local rules so the repository has deterministic policy-as-code before we add broader managed rule packs.

### Dependency vulnerability scanning

OWASP Dependency-Check scans Java dependencies for known CVEs.

Configuration:

```text
security/dependency-check/suppressions.xml
```

Local helper:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-dependency-check.ps1
```

Blocking rule:

- CVSS `7.0` or higher blocks release unless an approved exception exists.

### Code quality gate

SonarQube evaluates code quality, maintainability, reliability, security hotspots, duplication, and test coverage.

Configuration:

```text
app/pom.xml
app/sonar-project.properties
```

Jenkins integration:

```text
withSonarQubeEnv('sonarqube')
waitForQualityGate()
```

Blocking rule:

- Any failed or unavailable SonarQube quality gate blocks release.

### Container image scanning

Trivy scans the built container image for operating system and language package vulnerabilities.

Configuration:

```text
security/trivy/trivy.yaml
```

Local helper:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-trivy-image-scan.ps1 -Image secure-delivery-api:offline-test
```

Blocking rule:

- `HIGH` and `CRITICAL` fixed vulnerabilities block release.

The full JSON report is retained for triage, even when the blocking table scan focuses on actionable fixed vulnerabilities.

### Infrastructure as Code validation

Terraform is validated and scanned before deployment.

Local helpers:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate-terraform.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-iac-scan.ps1
```

Blocking rules:

- Terraform formatting failure blocks release.
- Terraform validation failure blocks release.
- High/critical IaC misconfigurations block release.

## Security model

The platform treats source contributions as untrusted and increases trust only after independent controls produce evidence. Trust attaches to an immutable artifact digest, not to a branch name or mutable image tag.

## Guiding principles

- Least privilege for people, jobs, and AWS roles
- Temporary credentials instead of static credentials
- No production secrets in pull-request execution
- Build once and promote the same image digest
- Fail closed when required release evidence is unavailable
- Time-bound, reviewable security exceptions
- Logs and evidence that are useful without exposing secrets
- Defense in depth without unexplained scanner duplication

## Required reading

- `architecture/trust-boundaries.md`
- `architecture/threat-model.md`
- `security/policies/security-gates.md`
- `security/policies/scanner-responsibilities.md`
- `docs/security/vulnerability-management.md`
- `docs/security/secrets-management.md`

## Change control

Changes to workflows, Jenkins pipelines, Terraform, scanner configuration, gate thresholds, and exception records are security-sensitive changes. They require review by an appropriate owner before entering the protected branch.

## Security is not proven by a green pipeline

A passing pipeline means the artifact satisfied the configured controls at a particular time. It does not prove the absence of vulnerabilities. Controls, rules, threat assumptions, dependencies, and exceptions must be reviewed as the platform evolves.
