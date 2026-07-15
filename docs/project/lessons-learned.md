# Lessons Learned

## 1. DevSecOps is evidence, not tool collection

The strongest part of the platform is not that it uses many scanners. The value is that each tool owns a clear control and produces release evidence.

## 2. Scanner failure is different from a finding

A failed scanner does not mean the code is vulnerable, but it also cannot be treated as a pass. Trusted release jobs should fail closed when required evidence is unavailable.

## 3. Windows/OneDrive can affect build reliability

JaCoCo coverage output and container bind mounts behaved differently on a OneDrive-backed Windows workspace. The solution was to copy source into the container filesystem before running Maven.

## 4. Image tags are not release identity

Tags can move. ECR digests are immutable. Production approval should reference the digest-based image URI.

## 5. Fast feedback and trusted release orchestration are different

GitHub Actions is excellent for PR feedback. Jenkins is better suited here for controlled release gates, scanner evidence, ECR push, and manual approval.

## 6. Local validation is not always the same as CI validation

Trivy and Dependency-Check need large vulnerability databases. Local network limits can block complete validation, while a properly cached Jenkins agent is the right long-term execution environment.
