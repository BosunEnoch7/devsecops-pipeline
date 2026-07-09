# GitHub Actions Guide

GitHub Actions is the first CI layer in this platform.

Its role is fast developer feedback, not production release authority.

## Current workflow

Workflow:

```text
.github/workflows/pr-validation.yml
```

Triggers:

- Pull requests targeting `main`
- Pushes to `main`
- Manual `workflow_dispatch`

The workflow runs only when the application or the workflow file changes.

## What the workflow validates

The workflow:

1. Checks out the source code.
2. Installs Java 21 with Eclipse Temurin.
3. Enables Maven dependency caching.
4. Runs:

   ```text
   mvn --batch-mode clean verify
   ```

5. Uploads test and coverage evidence.

## Security decisions

### Minimal token permissions

The workflow uses:

```yaml
permissions:
  contents: read
```

This follows least privilege. The PR validation workflow only needs to read repository content.

### No deployment secrets

This workflow does not use AWS credentials, ECR credentials, production secrets, or Jenkins release credentials.

Pull request workflows can execute code from branches that have not been trusted yet, so they should not receive production authority.

### Evidence retention

Test reports and JaCoCo coverage output are uploaded for 14 days.

This is long enough for review and troubleshooting, while avoiding unnecessary artifact storage.

## Why GitHub Actions before Jenkins?

GitHub Actions is close to the developer workflow. It gives fast PR feedback and integrates naturally with GitHub branch protection.

Jenkins will be used later for trusted release orchestration:

- Full security scanning
- Docker image build
- Container image scanning
- ECR push
- Manual production approval
- Deployment

This separation keeps PR feedback fast while preserving a stronger trust boundary around release operations.
