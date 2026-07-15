# Evidence Guide

This project is designed to be evaluated through evidence, not claims.

Recruiters and senior engineers should be able to open the repository and quickly see:

- what was built;
- which security controls exist;
- where each control runs;
- what evidence proves the control ran;
- what remains intentionally deferred.

## Evidence categories

| Category | Evidence | Why it matters |
| --- | --- | --- |
| Source control | GitHub repository screenshot | Proves clean project organization and professional presentation |
| Pull request validation | GitHub Actions passing workflow | Proves fast feedback before code reaches the trusted release pipeline |
| Release orchestration | Jenkins stage view | Proves controlled, auditable release sequencing |
| Code quality | SonarQube quality gate | Proves quality and maintainability are treated as release criteria |
| Secret detection | Gitleaks output | Proves secrets are checked before artifacts are promoted |
| SAST | Semgrep output | Proves source code is scanned for insecure patterns |
| Dependency security | OWASP Dependency-Check report | Proves third-party library risk is reviewed |
| Container security | Trivy image scan | Proves the built image is scanned before ECR promotion |
| IaC validation | Terraform validation and Trivy IaC scan | Proves infrastructure definitions are checked before use |
| Artifact integrity | ECR digest screenshot | Proves promotion is based on immutable image identity |
| Human control | Manual approval screenshot | Proves production promotion requires explicit approval |
| Runtime readiness | Health endpoint screenshot | Proves the application has a verifiable operational signal |

## Screenshot map

Save screenshots in the [`screenshots`](../../screenshots) folder using the naming convention in [`screenshots/README.md`](../../screenshots/README.md).

The most important screenshots for a portfolio review are:

1. `03-jenkins-pipeline-stage-view.png`
2. `05-sonarqube-quality-gate.png`
3. `10-trivy-container-scan.png`
4. `13-ecr-repository-image.png`
5. `14-ecr-image-digest.png`
6. `15-manual-production-approval.png`

If you only have time to capture six images, capture those first.

## What not to fake

Do not fake:

- successful scanner output;
- cloud resource screenshots;
- production approvals;
- vulnerability reports;
- ECR image digests.

If something could not run because of local network limits, document it honestly. In real DevSecOps, transparent limitations are better than polished but unverifiable claims.

## How to explain the project in interviews

Use this structure:

1. "The goal was to secure the software delivery lifecycle end to end."
2. "GitHub Actions handles fast pull request validation."
3. "Jenkins handles the trusted release path because it has stronger control over credentials, approvals, and archived evidence."
4. "Each security tool enforces a different class of control: secrets, SAST, dependencies, containers, IaC, and quality gates."
5. "The image is promoted to ECR only after gates pass."
6. "The release is approved by immutable digest, not by mutable tag."
7. "Runtime deployment is intentionally separated so infrastructure can consume a verified artifact."

## Final evidence review checklist

Before publishing the project:

- [ ] All screenshots are real and current.
- [ ] Sensitive values are hidden.
- [ ] README links render correctly on GitHub.
- [ ] Jenkins evidence artifacts are archived.
- [ ] ECR digest is visible.
- [ ] Manual approval shows the digest being approved.
- [ ] Documentation states what is complete and what is deferred.

