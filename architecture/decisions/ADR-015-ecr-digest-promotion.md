# ADR-015: Push verified images to Amazon ECR and promote by digest

## Status

Accepted

## Context

The pipeline needs a trusted registry for verified container images. Deployment approval should refer to an immutable artifact, not a mutable tag.

## Decision

Use Amazon ECR as the trusted container registry.

After Docker build and Trivy image scanning, Jenkins will:

1. Verify the ECR repository exists.
2. Authenticate to ECR.
3. Tag the local verified image with an ECR repository tag.
4. Push the image to ECR.
5. Capture the ECR image digest.
6. Store the digest as release evidence.

The release approval and later deployment should reference:

```text
repository-uri@sha256:digest
```

## Consequences

### Positive

- The promoted artifact has immutable identity.
- Manual approval can reference a specific image digest.
- Deployment can avoid mutable tag ambiguity.
- ECR becomes the controlled registry boundary.

### Trade-offs

- Jenkins needs tightly scoped AWS/ECR permissions.
- ECR repository creation must be handled separately by Terraform.
- Digest capture requires AWS CLI access after push.

## Security note

Production deployment must not rely only on mutable tags such as `latest`. Tags can be overwritten; digests identify exact image content.
