# STAR Stories

## Story 1: Reliable builds on Windows/OneDrive

**Situation:** The Java build appeared to hang when run through a Docker bind mount on a OneDrive-backed Windows workspace.

**Task:** Make the build reproducible and trustworthy for CI-style validation.

**Action:** I diagnosed that JaCoCo coverage output during JVM shutdown was unreliable through the synced bind mount. I changed the verification flow to copy source into the container filesystem and write build output inside Linux storage.

**Result:** The build became repeatable, tests passed, and the project gained a documented verification script.

## Story 2: Separating scanner failure from security findings

**Situation:** Some scanner validations failed because of registry/network/database download issues.

**Task:** Avoid confusing scanner execution failure with actual vulnerability findings.

**Action:** I updated scripts and troubleshooting docs to distinguish execution failure from findings, while keeping release behavior fail-closed.

**Result:** The pipeline became more accurate and production-minded: failed evidence is not treated as a pass, but incident response remains correct.

## Story 3: Digest-based artifact promotion

**Situation:** A release pipeline can push an image by tag, but tags can be overwritten.

**Task:** Make production approval traceable to an immutable artifact.

**Action:** I added ECR digest capture and hardened manual approval so approvers review the exact digest-based image URI.

**Result:** The release evidence can prove exactly which image was approved for deployment.
