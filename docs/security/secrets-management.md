# Secrets Management

## Core rules

- Secrets are never committed to Git.
- Secrets are never baked into container layers.
- Production credentials are unavailable to pull-request jobs.
- Temporary credentials are preferred over long-lived access keys.
- Credentials are scoped to a stage and purpose.
- Logs and screenshots must be sanitized.

## Planned secret locations

| Secret type | Planned control |
|---|---|
| GitHub integration secret | GitHub encrypted secret or application configuration |
| Jenkins service credential | Jenkins credential store with restricted job access |
| AWS access from Jenkins | Temporary credentials through IAM role assumption |
| SonarQube token | Jenkins credential store, injected only for analysis |
| Runtime application secret | AWS Secrets Manager or Systems Manager Parameter Store |
| Terraform backend access | IAM role rather than static credentials |

The exact runtime secret service will be selected when the sample application requirements are known.

## Secret detection

Gitleaks runs during trusted release validation. Detection rules may be tuned for the repository, but broad allowlists are prohibited.

Configuration:

```text
security/gitleaks/gitleaks.toml
```

Local scan helper:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-gitleaks.ps1
```

Jenkins release scan:

```text
gitleaks git --source .
```

The release pipeline generates redacted JSON and JUnit reports under:

```text
evidence/gitleaks/
```

The pipeline blocks on any unapproved probable secret.

## Response to a leaked secret

Removing the value from the latest commit does not make the credential safe.

Required response:

1. Revoke or rotate the credential immediately.
2. Determine where and when it was exposed.
3. Review provider audit logs for unauthorized use.
4. Replace the credential in authorized systems.
5. Remove the value from reachable history when appropriate.
6. Re-run secret detection.
7. Document cause, impact, and preventive action.

History rewriting is disruptive and does not replace rotation because clones, caches, logs, and forks may retain the value.

## Logging

Pipeline scripts must avoid command tracing around credentials. Secret masking is a secondary safeguard, not permission to print sensitive values. Reports and screenshots are reviewed before publication.
