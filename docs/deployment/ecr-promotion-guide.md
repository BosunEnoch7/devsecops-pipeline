# Amazon ECR Promotion Guide

Amazon ECR is the trusted container registry for this platform.

## Purpose

The pipeline pushes the verified container image to ECR and captures the immutable image digest.

The digest is the release identity.

Tags are useful labels, but tags can be moved. Digests identify exact image content.

## Jenkins assumptions

Jenkins needs:

- AWS CLI
- Docker CLI
- AWS credentials scoped to ECR push/read operations
- An existing ECR repository

Expected Jenkins credential:

```text
aws-ecr-push
```

Expected Jenkins parameter:

```text
AWS_REGION
ECR_REPOSITORY
```

Default repository name:

```text
secure-delivery-api
```

## ECR repository ownership

The release pipeline does not create the ECR repository.

ECR repository creation belongs to Terraform. The Jenkins release pipeline should fail if the expected repository does not exist.

This keeps infrastructure management separate from artifact promotion.

## Evidence

Jenkins writes ECR evidence under:

```text
evidence/ecr/
```

Expected evidence files:

- `aws-account-id.txt`
- `ecr-registry.txt`
- `ecr-repository.txt`
- `remote-image-tag.txt`
- `image-digest.txt`
- `image-uri-with-digest.txt`

## Local helper

From the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\push-image-to-ecr.ps1 -Image secure-delivery-api:offline-test -AwsRegion us-east-1 -EcrRepository secure-delivery-api -ImageTag local
```

Do not run this helper unless you are authenticated to the correct AWS account.

## Why digest capture matters

Bad release evidence:

```text
secure-delivery-api:latest
```

Better release evidence:

```text
123456789012.dkr.ecr.us-east-1.amazonaws.com/secure-delivery-api@sha256:...
```

The digest form proves exactly which image was approved and deployed.
