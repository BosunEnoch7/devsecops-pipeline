# Threat Model

## Scope

This threat model covers source contribution, CI/CD orchestration, security scanning, container creation, artifact storage, approval, and ECS deployment.

It does not claim to replace an application-specific threat model.

## Protected assets

- Source code and pipeline definitions
- GitHub, Jenkins, SonarQube, and AWS credentials
- Jenkins controller integrity
- Security policies and exception records
- Container images and image digests
- Terraform state
- Scan evidence and approval records
- Production workload and logs

## Primary threat actors

- An external attacker
- A malicious or compromised contributor account
- A compromised dependency or base image
- A compromised CI plugin or scanner
- An insider exceeding authorized access
- An accidental operator action

## Major threats and mitigations

| Threat | Impact | Principal mitigations |
|---|---|---|
| Secret committed to Git | Credential compromise | Local guidance, Gitleaks in PR and Jenkins, immediate rotation procedure |
| Malicious pull request accesses credentials | AWS or CI compromise | GitHub-hosted untrusted jobs, no production secrets, restricted token permissions |
| Workflow or Jenkinsfile tampering | Security-gate bypass | CODEOWNERS, protected branch, required review, pipeline changes treated as privileged |
| Forged Jenkins trigger | Unauthorized build or deployment | Signed webhook, event validation, protected-branch verification |
| Vulnerable dependency | Application compromise | Dependency-Check, Trivy, version policy, time-bound exceptions |
| Malicious dependency or base image | Supply-chain compromise | Trusted registries, pinning, digest tracking, minimal dependencies, future signing |
| Jenkins controller compromise | Release-system takeover | Private placement, patching, minimal plugins, no controller builds, backups, least privilege |
| Build-agent contamination | Cross-build compromise | Replaceable agents, clean workspaces, restricted credentials |
| Docker socket abuse | Host-level compromise | Isolated agent design and documented Docker build strategy |
| Scanner bypass or false result | Unsafe artifact promoted | Multiple complementary controls, version pinning, retained evidence, policy review |
| Mutable image tag changed | Wrong artifact deployed | ECR tag immutability and digest-based deployment |
| Approval applies to wrong image | Unauthorized artifact in production | Approval screen and record contain commit, build, and digest |
| Terraform state exposure | Credential or infrastructure disclosure | Encrypted remote state, access control, locking, no state in Git |
| Overprivileged IAM role | Excessive blast radius | Separate roles, least privilege, temporary credentials, CloudTrail |
| Publicly exposed Jenkins/SonarQube | Service compromise | Private subnets or tightly controlled ingress, TLS, authentication |
| Vulnerability exception never revisited | Permanent hidden risk | Named owner, justification, compensating control, approval, expiry |

## Highest-risk design areas

### CI pipeline code

Pipeline definitions execute with elevated access. Changes under `.github/`, `jenkins/`, `security/`, and `terraform/` require heightened review.

### Build mechanism

Granting a Jenkins agent access to a Docker daemon can become equivalent to host-root access. Before implementation we will choose and document either a tightly isolated dedicated builder or a daemonless build approach.

### Production approval

A manual click is not automatically a security control. The approval must show the exact artifact digest, evidence, approver, and timestamp, and deployment must consume that same digest.

## Residual risks

- Static analysis cannot prove that software is vulnerability-free.
- Public vulnerability databases may lag behind newly discovered issues.
- A trusted maintainer or CI administrator can still cause high-impact changes.
- Single-instance Jenkins and SonarQube create availability risks in the initial cost-conscious design.
- Until artifact signing is implemented, digest integrity depends on AWS, IAM, and ECR controls.

These risks are accepted initially only with clear ownership and a roadmap for improvement.

