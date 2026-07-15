# Jenkins Release Pipeline Stages

This document explains the intended release pipeline stages and why each exists.

## 1. Checkout trusted source

Jenkins checks out the repository and records the commit SHA.

Why it matters:

- Release evidence must point to an exact commit.
- Later image tags and deployment records must trace back to source.

## 2. Validate release context

Jenkins records branch, build URL, build number, and commit metadata.

Why it matters:

- Release jobs should be traceable.
- Debugging failed releases is easier when context is archived.

## 3. Lint and unit tests

The Java application is built with Maven and tests are executed.

Why it matters:

- Security pipelines still start with correctness.
- A vulnerable-but-working app is bad; a secure-but-broken app is also bad.

## 4. SonarQube quality gate

SonarQube will enforce quality and maintainability rules.

Why it matters:

- Complex code tends to hide defects.
- Quality gates stop risky code from moving forward.

## 5. Secret scanning

Gitleaks will scan for committed secrets.

Why it matters:

- Secrets in Git history must be treated as compromised.
- Catching secrets before image build reduces blast radius.

## 6. Static application security testing

Semgrep will scan source code for insecure patterns.

Why it matters:

- SAST catches classes of bugs before runtime.
- It helps developers learn secure coding patterns.

## 7. Dependency vulnerability scanning

OWASP Dependency-Check will inspect application dependencies.

Why it matters:

- Modern applications inherit risk through libraries.
- Dependency findings need policy-based triage.

## 8. Infrastructure validation

Terraform formatting, validation, and IaC scanning will run before deployment.

Why it matters:

- Infrastructure is part of the product.
- Misconfigured infrastructure can expose a secure app.

## 9. Docker build

Jenkins builds the application image.

Why it matters:

- The image becomes the deployable artifact.
- Later stages scan, tag, push, and promote this artifact.

## 10. Container image scanning

Trivy will scan the built image.

Why it matters:

- Runtime images contain operating system packages and dependencies.
- Image scanning verifies what will actually run.

## 11. Artifact identity

The pipeline captures image identity.

Why it matters:

- Production approval must reference an exact artifact.
- Later ECR digest promotion depends on this control.

## 12. Push image to Amazon ECR

Jenkins pushes the verified image to ECR and captures the immutable digest.

Why it matters:

- ECR becomes the trusted image registry.
- Deployment should pull by digest, not by mutable tag alone.
- Manual approval should reference the digest-based image URI.

## 13. Manual production approval

A human approves production release after reviewing evidence and the exact ECR image digest.

Why it matters:

- Manual approval creates an intentional release decision.
- The approver should approve a specific artifact and evidence set.
- Approval by digest prevents mutable-tag ambiguity.

## 14. Deployment

The approved artifact is deployed.

Why it matters:

- Deployment should be the final promotion of already-verified evidence.
- Post-deployment verification will confirm the service is healthy.
