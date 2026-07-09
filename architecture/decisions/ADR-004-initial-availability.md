# ADR-004: Begin with Recoverable Single-Instance CI Services

## Status

Proposed for implementation.

## Decision

The initial Jenkins controller and SonarQube service will be cost-conscious single-instance deployments on controlled Ubuntu EC2 infrastructure, with backups and recovery documentation.

## Why

Multi-node availability would add cost and distract from secure delivery controls. We will not misrepresent the initial platform as highly available.

## Consequences

Maintenance or instance failure can interrupt delivery. Backup restoration, infrastructure recreation, and future high-availability options must be documented and tested.

