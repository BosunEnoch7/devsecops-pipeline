# LinkedIn Post

I just built a flagship DevSecOps project: `devsecops-pipeline`.

The goal was not just to create a CI/CD pipeline, but to model how secure software delivery works in a production-inspired environment.

What I implemented:

- GitHub Actions PR validation
- Jenkins trusted release pipeline
- Java/Spring Boot sample workload
- Docker image hardening
- SonarQube quality gate
- Gitleaks secret scanning
- Semgrep SAST
- OWASP Dependency-Check
- Trivy container and IaC scanning
- Terraform validation
- Amazon ECR image promotion
- Digest-based manual approval
- Architecture docs, threat model, ADRs, and troubleshooting guides

The biggest lesson: DevSecOps is not about adding random tools. It is about creating trustworthy release evidence at every stage of the software delivery lifecycle.

Tags can move. Digests prove artifact identity.

Scanners can fail. A failed scanner is not a pass.

Security gates need clear ownership, thresholds, and evidence.

This project deepened my understanding of secure CI/CD, release engineering, cloud artifact promotion, and production-style documentation.

#DevSecOps #Jenkins #GitHubActions #AWS #Docker #Terraform #CloudSecurity #SRE #PlatformEngineering
