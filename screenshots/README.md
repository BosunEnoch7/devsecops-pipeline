# Evidence Screenshots

This folder is reserved for real screenshots captured from the finished DevSecOps pipeline.

Do not add fabricated screenshots. Each image should prove that a specific control, gate, or delivery stage actually ran.

## Recommended filenames

Use these exact names so the README and documentation remain easy to navigate:

| File | What it should show |
| --- | --- |
| `01-github-repository-home.png` | GitHub repository homepage with project structure visible |
| `02-github-actions-pr-validation.png` | GitHub Actions PR validation workflow passing |
| `03-jenkins-pipeline-stage-view.png` | Jenkins release pipeline with major stages visible |
| `04-jenkins-archived-artifacts.png` | Jenkins archived reports/evidence artifacts |
| `05-sonarqube-quality-gate.png` | SonarQube project dashboard and quality gate result |
| `06-gitleaks-secret-scan.png` | Gitleaks stage output showing secret scan result |
| `07-semgrep-sast-scan.png` | Semgrep SAST output showing scan result |
| `08-dependency-check-report.png` | OWASP Dependency-Check report summary |
| `09-docker-build-output.png` | Docker image build output |
| `10-trivy-container-scan.png` | Trivy container image scan result |
| `11-terraform-validation.png` | Terraform formatting/validation output |
| `12-trivy-iac-scan.png` | Trivy IaC scan result |
| `13-ecr-repository-image.png` | Amazon ECR repository with pushed image |
| `14-ecr-image-digest.png` | ECR image digest evidence |
| `15-manual-production-approval.png` | Jenkins manual approval prompt by digest |
| `16-container-health-check.png` | Application health endpoint response |
| `17-final-readme-rendered.png` | Final README rendered on GitHub |

## Capture rules

- Prefer PNG screenshots.
- Crop only distracting browser chrome, not important evidence.
- Hide or blur account IDs, tokens, emails, and any private URLs before committing.
- Keep timestamps visible when they help prove execution.
- Capture the full stage/result where possible, not only a tiny success badge.
- If a scanner is intentionally blocked by network/database access locally, capture the Jenkins stage configuration or script output and explain the limitation in the project notes.

## Interview framing

When discussing these screenshots, explain the security control first, then the tool:

- Instead of: "This is Trivy."
- Say: "This proves the release pipeline blocks vulnerable container images before promotion to ECR, and Trivy is the scanner enforcing that gate."

