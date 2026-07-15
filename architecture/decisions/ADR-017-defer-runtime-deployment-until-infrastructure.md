# ADR-017: Defer runtime deployment until infrastructure exists

## Status

Accepted

## Context

The pipeline can build, scan, push, and approve a container image. However, runtime infrastructure such as ECS service, load balancer, task definition, IAM roles, and networking has not yet been created.

## Decision

Do not fake a production deployment.

The Jenkins deployment stage records the approved image digest and marks deployment as deferred until runtime infrastructure is implemented.

## Consequences

### Positive

- The pipeline remains honest.
- Release evidence still proves artifact readiness.
- Future ECS deployment can consume the approved digest without changing earlier gates.

### Trade-offs

- The current project demonstrates deployment readiness, not live workload rollout.
- A future ECS enhancement must add infrastructure and service update logic.

## Security note

Deployment must consume the approved digest URI. It must not substitute a mutable tag after approval.
