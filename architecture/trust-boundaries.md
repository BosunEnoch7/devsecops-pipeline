# Trust Boundaries

## Security principle

Data crossing a trust boundary must be authenticated, authorized, validated, and observable. A successful upstream stage does not grant unlimited trust to downstream systems.

## Boundary 1: Developer workstation to GitHub

The workstation is not inherently trusted. Commits and pull requests may contain vulnerable code, malicious workflow changes, or leaked secrets.

Controls:

- Pull requests instead of direct production-branch pushes
- Required reviews and status checks
- Secret and static-analysis checks
- CODEOWNERS review for workflows, Jenkins, security policy, and Terraform
- Least-privilege GitHub tokens

## Boundary 2: Pull request to trusted branch

Pull-request code is untrusted, particularly when contributed from a fork. It must not gain production secrets or execute arbitrary commands on a privileged self-hosted runner.

Controls:

- GitHub-hosted runners for untrusted checks
- No AWS production credentials in pull-request jobs
- Restricted workflow permissions
- Trusted release begins only after protected-branch merge
- Review required for workflow and pipeline changes

## Boundary 3: GitHub to Jenkins

A webhook or API trigger is an external input to Jenkins. A trigger must not prove that a release is authorized by itself.

Controls:

- Verify webhook authenticity
- Restrict the exposed Jenkins endpoint
- Re-fetch the repository from the configured origin
- Validate repository, branch, and commit
- Avoid accepting arbitrary pipeline parameters from webhook payloads
- Record the GitHub event and commit in build metadata

## Boundary 4: Jenkins controller to build agent

Build code can be hostile or compromised. Running builds on the controller would put Jenkins configuration and credentials at risk.

Controls:

- No builds on the controller
- Dedicated, replaceable agent
- Minimal tools and plugins
- Workspace cleanup between builds
- Stage-scoped credentials
- No unrestricted Docker socket exposure without an explicit risk decision

## Boundary 5: Jenkins to security services

Source code and metadata cross into SonarQube and scanner processes.

Controls:

- Private connectivity where practical
- Authenticated SonarQube access
- Short-lived or narrowly scoped tokens
- Sanitized logs and reports
- Version-pinned scanner execution

## Boundary 6: Jenkins to AWS

Jenkins can create or promote artifacts, so compromise here has high impact.

Controls:

- Prefer temporary AWS credentials through an assumed IAM role
- Separate ECR-push and production-deployment permissions
- Restrict roles by repository, environment, and required actions
- CloudTrail audit logging
- No long-lived AWS access keys in source code or images

## Boundary 7: ECR to ECS

The registry contains many possible images, but production must run only the approved artifact.

Controls:

- Deploy by digest
- Enable tag immutability
- Restrict ECR repository access
- Record the digest in deployment evidence
- Apply lifecycle policy without deleting active rollback images

## Boundary 8: User traffic to the workload

Internet traffic is untrusted.

Controls:

- Application Load Balancer as the public entry point
- TLS termination
- Private ECS tasks with no public IP
- Security groups allowing only required paths
- Health checks, access logs, and application logs

## Sensitive data

The following must not be committed or exposed in screenshots and build logs:

- AWS credentials and account details not required for evidence
- GitHub and Jenkins tokens
- SonarQube tokens
- Webhook secrets
- Terraform state
- Application secrets
- Scanner reports containing exploitable internal details

