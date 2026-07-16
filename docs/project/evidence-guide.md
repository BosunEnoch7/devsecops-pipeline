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
| Source control | Git history and repository structure | Proves clean project organization and professional presentation |
| Pull request validation | GitHub Actions workflow definition | Proves fast feedback before code reaches the trusted release pipeline |
| Release orchestration | Jenkins stage view | Proves controlled, auditable release sequencing |
| Code quality | SonarQube quality gate | Proves quality and maintainability are treated as release criteria |
| Secret detection | Gitleaks output | Proves secrets are checked before artifacts are promoted |
| SAST | Semgrep output | Proves source code is scanned for insecure patterns |
| Dependency security | OWASP Dependency-Check report | Proves third-party library risk is reviewed |
| Container security | Trivy image scan | Proves the built image is scanned before ECR promotion |
| IaC validation | Terraform validation and Trivy IaC scan | Proves infrastructure definitions are checked before use |
| Artifact integrity | ECR digest record | Proves promotion is based on immutable image identity |
| Human control | Manual approval record | Proves production promotion requires explicit approval |
| Runtime readiness | Health endpoint response | Proves the application has a verifiable operational signal |

## What not to fake

Do not fake:

- successful scanner output;
- cloud resource claims;
- production approvals;
- vulnerability reports;
- ECR image digests.

If something could not run because of local network limits, document it honestly. In real DevSecOps, transparent limitations are better than polished but unverifiable claims.

## Final evidence review checklist

Before publishing the project:

- [ ] Evidence statements are accurate.
- [ ] Sensitive values are hidden or excluded.
- [ ] README links render correctly on GitHub.
- [ ] Jenkins evidence artifacts are archived.
- [ ] ECR digest is visible.
- [ ] Manual approval shows the digest being approved.
- [ ] Documentation states what is complete and what is deferred.
