# ADR-016: Require production approval by immutable image digest

## Status

Accepted

## Context

Manual approval is only meaningful when the approver knows exactly what artifact is being approved. A mutable tag can be overwritten after approval, creating ambiguity or release risk.

## Decision

The Jenkins production approval step must display and record the ECR image URI with digest:

```text
repository-uri@sha256:digest
```

The pipeline blocks approval if the digest evidence is missing or malformed.

## Consequences

### Positive

- Approval references an immutable artifact.
- Deployment evidence can be tied back to the approved image.
- Tag mutation cannot silently change the approved artifact.

### Trade-offs

- The ECR push/digest capture stage must complete before approval.
- The approval message depends on archived evidence being present and readable.

## Security note

Approvers should review the release evidence before approving:

- Commit SHA
- Test results
- Scanner reports
- ECR digest
- Exceptions, if any
