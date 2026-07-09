# ADR-003: Build Once and Promote by Image Digest

## Status

Proposed for implementation.

## Decision

Jenkins will build a container once. Security evidence, approval, and deployment will reference its ECR digest.

## Why

Rebuilding after approval could change dependencies or image contents. Digest-based promotion proves which artifact was evaluated and deployed.

## Consequences

The pipeline must capture metadata reliably, ECR tag immutability must be enabled, and rollback images must be retained.

