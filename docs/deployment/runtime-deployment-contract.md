# Runtime Deployment Contract

The platform currently promotes a verified image to ECR and captures the approved digest.

Runtime deployment is intentionally deferred until the ECS infrastructure phase is implemented.

## Deployment input

Deployment must consume:

```text
evidence/approved-image-uri.txt
```

The value must look like:

```text
123456789012.dkr.ecr.us-east-1.amazonaws.com/secure-delivery-api@sha256:...
```

## Deployment rule

Deploy by digest, not by mutable tag.

## Future ECS deployment flow

The ECS deployment stage will:

1. Read the approved digest URI.
2. Render a new ECS task definition revision.
3. Set the container image to the digest URI.
4. Update the ECS service.
5. Wait for service stability.
6. Run health/smoke checks.
7. Archive deployment evidence.

## Current Jenkins behavior

Until runtime infrastructure exists, Jenkins records:

```text
DEPLOYMENT_DEFERRED
```

This is intentional. It shows the release artifact is ready but avoids pretending that a production runtime exists before Terraform creates one.
