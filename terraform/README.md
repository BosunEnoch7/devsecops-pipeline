# Terraform

This folder contains Infrastructure as Code for the DevSecOps platform.

## Current phase

Phase 15 introduces Terraform structure and validation gates without deploying AWS resources yet.

The goal is to make infrastructure changes reviewable and testable before we add ECR, ECS, ALB, IAM, and networking resources.

## Structure

```text
terraform/
  bootstrap/
  environments/
    dev/
  modules/
```

## Validation

From the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate-terraform.ps1
```

The validation script runs:

```text
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

## IaC security scanning

From the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-iac-scan.ps1
```

The IaC scan uses Trivy configuration scanning to detect Terraform misconfigurations before resources exist in AWS.

## Backend strategy

The environment includes an S3 backend block, but validation runs with:

```text
terraform init -backend=false
```

This allows CI to validate Terraform syntax and module structure without requiring access to the real remote state backend.

Remote state configuration will be introduced when we build the AWS deployment foundation.
