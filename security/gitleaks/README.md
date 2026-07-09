# Gitleaks

Gitleaks detects secrets committed to source control.

Configuration:

```text
security/gitleaks/gitleaks.toml
```

## What it scans

In Jenkins release jobs, Gitleaks scans Git history:

```text
gitleaks git --source .
```

This matters because deleting a secret from the latest file is not enough. If the secret was committed, it may still exist in Git history.

## Blocking policy

Any unapproved probable secret blocks the release pipeline.

There are only three acceptable outcomes:

1. False positive documented and allowlisted narrowly.
2. Secret removed before merge.
3. Real secret rotated/revoked, history remediated if required, and incident notes captured.

Do not simply delete the value and continue if the secret may already have been exposed.

## Reports

The Jenkins pipeline produces:

- `evidence/gitleaks/gitleaks.json`
- `evidence/gitleaks/gitleaks-junit.xml`

Reports are generated with redaction enabled so the pipeline does not archive raw secrets.

## Local usage

From the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-gitleaks.ps1
```

The script uses a locally installed `gitleaks` binary if available. Otherwise, it uses the official container image:

```text
ghcr.io/gitleaks/gitleaks:latest
```
