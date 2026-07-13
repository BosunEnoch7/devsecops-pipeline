# Trivy

Trivy is the platform's container image vulnerability scanner.

Configuration:

```text
security/trivy/trivy.yaml
```

## What it scans

Trivy scans the built container image, not just Maven dependencies.

This matters because the final image can contain:

- Operating system packages
- Java runtime packages
- Application dependencies
- Files copied during image build

Dependency-Check tells us about Java dependencies. Trivy tells us about the deployable image.

This stage uses:

```text
--scanners vuln
```

Secret scanning remains owned by Gitleaks so scanner responsibilities stay clear.

## Blocking policy

The release pipeline blocks on:

- `HIGH`
- `CRITICAL`

The blocking scan uses:

```text
--ignore-unfixed
```

That means the first blocking policy focuses on vulnerabilities where a fix is available. Full JSON evidence is still archived for broader review.

## Reports

Jenkins produces:

- `evidence/trivy/trivy-image.json`
- `evidence/trivy/trivy-image-table.txt`

## Local usage

From the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-trivy-image-scan.ps1 -Image secure-delivery-api:offline-test
```

If the Java vulnerability database download is too slow during local validation, validate only operating system packages:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-trivy-image-scan.ps1 -Image secure-delivery-api:offline-test -PackageTypes os
```

That local shortcut is not the full Jenkins policy. Jenkins should scan both:

```text
os,library
```

The helper uses a local `trivy` binary when available. If Trivy is not installed, it exports the local Docker image to a tarball and scans it with the official Trivy container image:

```text
aquasec/trivy:latest
```

## First-run warning

The first Trivy run downloads a vulnerability database. This can take time and requires registry/network access.

The local helper mounts a Docker volume named:

```text
devsecops-trivy-cache
```

This allows later local scans to reuse the Trivy vulnerability database cache.
