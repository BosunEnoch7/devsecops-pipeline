# Screenshots Checklist

Capture these screenshots before publishing the final project.

Use the exact filenames documented in [`screenshots/README.md`](../../screenshots/README.md) so the evidence pack is consistent and easy to review.

## Required evidence

- [x] `01-github-repository-home.png` - GitHub repository homepage
- [x] `02-github-actions-pr-validation.png` - GitHub Actions PR validation passing
- [ ] `03-jenkins-pipeline-stage-view.png` - Jenkins pipeline stage view
- [ ] `04-jenkins-archived-artifacts.png` - Jenkins archived evidence artifacts
- [ ] `05-sonarqube-quality-gate.png` - SonarQube project dashboard and quality gate
- [ ] `06-gitleaks-secret-scan.png` - Gitleaks stage output
- [ ] `07-semgrep-sast-scan.png` - Semgrep scan output
- [ ] `08-dependency-check-report.png` - Dependency-Check report
- [ ] `09-docker-build-output.png` - Docker image build output
- [ ] `10-trivy-container-scan.png` - Trivy image scan evidence
- [ ] `11-terraform-validation.png` - Terraform validation output
- [ ] `12-trivy-iac-scan.png` - Trivy IaC scan output
- [ ] `13-ecr-repository-image.png` - Amazon ECR repository with pushed image
- [ ] `14-ecr-image-digest.png` - ECR image digest evidence
- [ ] `15-manual-production-approval.png` - Manual approval step in Jenkins
- [ ] `16-container-health-check.png` - Container health endpoint response
- [x] `17-final-readme-rendered.png` - Final README rendered on GitHub

## Priority order

If time is limited, capture these first:

1. Jenkins pipeline stage view
2. SonarQube quality gate
3. Trivy container scan
4. ECR image digest
5. Manual production approval
6. Final GitHub README

## Mentorship note

Screenshots are not decoration. They are audit evidence.

In real teams, an approval without evidence is weak. A release with archived scanner reports, immutable image digest, and visible approval trail is much easier to defend during audits, incident reviews, and production change reviews.
