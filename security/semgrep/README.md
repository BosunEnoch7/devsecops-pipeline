# Semgrep

Semgrep is the platform's Static Application Security Testing control.

Configuration:

```text
security/semgrep/semgrep.yml
```

Ignore file:

```text
.semgrepignore
```

## Why local rules first?

Semgrep can use remote registry packs, but this project starts with repository-owned rules.

This gives us:

- Deterministic scans
- Reviewable policy-as-code
- No dependency on network access for the baseline rules
- A clear foundation before adding broader managed rule packs

## Blocking policy

Semgrep findings with `ERROR` severity block the trusted release pipeline.

## Scan scope

The current scan targets are:

- `app`
- `docker`

We intentionally avoid scanning the entire repository in this phase because documentation, screenshots, generated files, and local workspace metadata create noise and slow scans. The scope will expand when Terraform and other deployable assets are implemented.

## Reports

The Jenkins pipeline produces:

- `evidence/semgrep/semgrep.json`
- `evidence/semgrep/semgrep-junit.xml`

## Local usage

From the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-semgrep.ps1
```

The helper uses a locally installed `semgrep` binary if available. Otherwise, it attempts to run the official Semgrep container image:

```text
semgrep/semgrep:latest
```
