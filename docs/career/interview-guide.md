# Interview Guide

## Project pitch

I built a production-inspired DevSecOps platform that secures the software delivery lifecycle from source control to artifact promotion. The pipeline uses GitHub Actions for fast PR validation and Jenkins for trusted release orchestration. It integrates quality gates, SAST, secret scanning, dependency scanning, IaC validation, container image scanning, ECR promotion, digest capture, and manual approval.

## Questions to prepare for

### Why use both GitHub Actions and Jenkins?

GitHub Actions is close to the developer workflow and gives fast PR feedback. Jenkins is used for trusted release orchestration because it can run controlled agents, manage release credentials, archive evidence, and enforce manual approval.

### Why approve by digest instead of tag?

Tags are mutable. A digest identifies exact image content. Approving `image:latest` is ambiguous; approving `repository@sha256:...` is auditable.

### What does fail closed mean?

If a required scanner cannot run, the release does not continue. A scanner outage is different from a vulnerability finding, but neither should silently pass a trusted release gate.

### What is the difference between Dependency-Check and Trivy?

Dependency-Check scans Maven dependencies for known CVEs. Trivy scans the final container image, including OS and language packages. They overlap, but they answer different questions.

### What would you improve next?

I would add ECS runtime infrastructure, OIDC-based AWS authentication, SBOM generation, image signing, policy-as-code with OPA/Conftest, and post-deployment smoke checks.

## Strong talking points

- Clear trust boundary between PR validation and release pipeline.
- Evidence-driven security gates.
- Digest-based artifact promotion.
- Scanner responsibility separation.
- Practical handling of local environment limitations.
- Production-style documentation and ADRs.
