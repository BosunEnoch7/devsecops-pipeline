# OWASP Dependency-Check

OWASP Dependency-Check identifies known vulnerabilities in third-party dependencies.

Suppression file:

```text
security/dependency-check/suppressions.xml
```

## What it scans

The current target is the Java/Maven application:

```text
app/pom.xml
```

Dependency-Check analyzes direct and transitive dependencies and compares evidence against vulnerability data sources such as the National Vulnerability Database.

## Blocking policy

The release pipeline blocks when Dependency-Check identifies a vulnerability with CVSS score `7.0` or higher unless there is an approved suppression/exception.

Why `7.0`?

- CVSS 7.0+ generally maps to high/critical severity.
- High and critical findings deserve release-level attention.
- Medium/low findings still matter, but they can usually be triaged without automatically blocking the first version of the platform.

## Suppressions

Suppressions are not a shortcut.

They are allowed only when:

- The finding is a confirmed false positive.
- The vulnerable code path is not reachable and the risk is documented.
- There is an approved temporary exception with an owner and expiration date.

Broad suppressions are prohibited.

## Local usage

From the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-dependency-check.ps1
```

Reports are written to:

```text
.build/dependency-check/
```

## First-run warning

The first run can take a long time because Dependency-Check must download and process vulnerability data. Subsequent runs are faster when cache data is reused.

Dependency-Check strongly benefits from an NVD API key. For this Jenkins release pipeline, configure one so release jobs do not suffer slow unauthenticated NVD updates.

For Jenkins, store the key as a secret text credential:

```text
nvd-api-key
```

The Jenkinsfile injects that credential only into the Dependency-Check stage.

For local runs:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-dependency-check.ps1 -NvdApiKey "<your-key>"
```
