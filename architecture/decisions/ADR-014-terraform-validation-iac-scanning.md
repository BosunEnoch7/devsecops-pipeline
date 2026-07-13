# ADR-014: Validate Terraform and scan IaC before deployment

## Status

Accepted

## Context

Infrastructure misconfiguration can expose otherwise secure workloads. Terraform changes should be validated and scanned before deployment.

## Decision

Introduce Terraform validation and IaC scanning before adding real AWS resources.

The validation gate runs:

- `terraform fmt -check -recursive`
- `terraform init -backend=false`
- `terraform validate`
- Trivy IaC misconfiguration scanning

## Consequences

### Positive

- Terraform quality gates exist before AWS resources are introduced.
- CI can validate Terraform without remote state access.
- IaC misconfigurations are caught before deployment.
- The environment structure is ready for ECR/ECS/ALB phases.

### Trade-offs

- The first Terraform environment is intentionally minimal.
- Validation does not prove AWS permissions or runtime cloud behavior.
- Trivy IaC findings still require human triage.

## Security note

Terraform validation must not require production AWS credentials in pull-request or low-trust contexts.
