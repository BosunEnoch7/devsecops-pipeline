# ADR-006: Harden the application container image

## Status

Accepted

## Context

The platform needs a production-inspired container image for the sample workload. The image must support later DevSecOps controls such as Trivy scanning, ECR push, digest-based promotion, and deployment approval.

## Decision

Use a multi-stage Docker build:

- Maven with Eclipse Temurin 21 for the build stage.
- Eclipse Temurin 21 JRE for the runtime stage.
- Non-root application user with UID/GID `10001`.
- Reduced Docker build context through `.dockerignore`.
- OCI image labels for traceability.
- No secrets passed through Docker `ARG` or `ENV`.

## Consequences

### Positive

- Build tools are excluded from the runtime image.
- The running container has lower privilege.
- Image metadata can be tied back to pipeline evidence.
- The image is easier to scan and reason about.

### Trade-offs

- The Dockerfile currently uses versioned image tags rather than immutable digests. The pipeline will record image digests after build and use digest-based promotion.
- The runtime image does not include `curl`, so container-native HTTP health checks are not embedded in the image. The orchestrator should call `/actuator/health`.
- Tests are not re-run inside the Docker build because test execution is handled earlier in the pipeline.

## Security note

If future builds need access to private package repositories, credentials must be provided through CI secret stores or Docker BuildKit secret mounts, not through Docker build arguments.
