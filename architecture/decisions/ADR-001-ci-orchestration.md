# ADR-001: Split CI Responsibilities Between GitHub Actions and Jenkins

## Status

Proposed for implementation.

## Decision

GitHub Actions will validate proposed source changes. Jenkins will perform trusted release builds, artifact publication, approval, and deployment.

## Why

GitHub Actions provides fast repository-native feedback. Jenkins provides controlled workers, private integrations, explicit approvals, and enterprise release orchestration.

## Trade-offs

Operating two systems increases maintenance and creates an integration boundary. We accept this because the project explicitly demonstrates hybrid enterprise delivery. Duplicate checks must be intentional, not accidental.

