# System Overview

## Purpose

This platform demonstrates a secure path from an untrusted source-code change to an approved, immutable production container.

The design separates three concerns:

1. GitHub governs source changes.
2. Jenkins builds and verifies release artifacts.
3. AWS stores and deploys approved artifacts.

## Target architecture

```text
Developer
   |
   v
GitHub repository
   |
   +--> GitHub Actions: fast pull-request checks
   |
   v
Protected branch merge
   |
   v
Jenkins on Ubuntu EC2
   |
   +--> SonarQube
   +--> Gitleaks
   +--> Semgrep
   +--> OWASP Dependency-Check
   +--> Docker build
   +--> Trivy image scan
   |
   v
Amazon ECR: immutable image digest
   |
   v
Manual production approval
   |
   v
Amazon ECS Fargate
   |
   v
Post-deployment health and smoke checks
```

## Component responsibilities

### GitHub

GitHub is the source of truth for application, pipeline, security policy, and infrastructure changes. The default branch will be protected by pull requests, review, and required status checks.

### GitHub Actions

GitHub Actions provides fast feedback for untrusted proposed changes. It must not hold production deployment credentials. Its initial responsibilities will be linting, unit tests, secret scanning, Semgrep, and Terraform validation.

### Jenkins

Jenkins is the trusted release orchestrator. It performs the complete security evaluation, creates the container once, records evidence, pushes the verified artifact to ECR, obtains approval, and deploys the approved digest.

The Jenkins controller must not execute builds. Build work should run on a dedicated, replaceable agent with only the permissions required by its stage.

### SonarQube

SonarQube receives source analysis from Jenkins and returns a quality-gate decision. It is not directly internet-facing.

### Amazon ECR

ECR is the verified artifact boundary. Images are tagged with the Git commit SHA and addressed by immutable digest. Production never deploys the mutable `latest` tag.

### Amazon ECS Fargate

ECS Fargate runs the sample production workload without requiring management of container hosts. The ECS task execution role retrieves the image and logs; the application task role receives only application-specific AWS permissions.

## Artifact promotion model

The pipeline builds one image and computes its digest. All scan evidence and approvals refer to that digest. Production deploys the same digest; it does not rebuild source after approval.

This creates traceability:

```text
Git commit SHA -> Jenkins build -> scan evidence -> ECR digest -> approval -> ECS task definition
```

## Environment model

The initial implementation will use a non-production environment before production. Separate Terraform composition and separate deployment roles will prevent a development credential from becoming an implicit production credential.

For portfolio cost control, environments may share carefully selected foundational services, but security boundaries and permissions must remain explicit.

## Availability and recovery scope

This is production-inspired rather than a claim of full enterprise high availability. The first release prioritizes reproducibility, backup, and documented recovery for Jenkins and SonarQube. Multi-node high availability is a documented future improvement because it adds significant cost and operational complexity.

