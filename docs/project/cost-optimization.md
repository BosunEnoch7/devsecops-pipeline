# Cost Optimization

## Current cost posture

The project is designed to avoid unnecessary AWS spend during local development.

Runtime deployment is deferred until infrastructure is intentionally provisioned.

## Cost controls

- Do not create ECR repositories from Jenkins release jobs.
- Use Terraform to manage infrastructure intentionally.
- Avoid always-on compute until deployment infrastructure is required.
- Stop or destroy non-production resources after demos.
- Use short artifact retention windows where appropriate.
- Cache scanner databases on Jenkins agents to avoid repeated expensive downloads.
- Prefer ECS Fargate for workload runtime to avoid unmanaged idle EC2 instances.

## Resources to watch

- NAT gateways
- Load balancers
- EC2 instances
- RDS databases
- EKS clusters
- Elastic IPs
- Large ECR image storage
- CloudWatch log retention

## Current AWS check

On July 15, 2026, a read-only Cost Explorer check showed only near-zero fractional charges for the current month. No major live compute cost driver was confirmed in `us-east-1`.
