# ADR-002: Deploy the Sample Workload to Amazon ECS Fargate

## Status

Proposed for implementation.

## Decision

The production-inspired workload will run on Amazon ECS Fargate behind an Application Load Balancer.

## Why

ECS Fargate demonstrates AWS container security, IAM roles, private networking, immutable image promotion, health checks, and deployment controls without making Kubernetes operations the main project.

## Trade-offs

Fargate offers less host-level control and can cost more than densely utilized EC2 capacity. Those constraints are acceptable for this security-delivery learning goal.

