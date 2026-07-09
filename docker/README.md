# Docker

This folder contains container-build assets for the DevSecOps platform.

## Application image

The application image is defined in:

```text
docker/app/Dockerfile
```

Build it from the repository root:

```powershell
.\scripts\build-app-image.ps1
```

If PowerShell blocks local scripts:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-app-image.ps1
```

If Docker Hub is temporarily unreachable but the Maven builder image is already cached locally, you can verify Dockerfile mechanics with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-app-image.ps1 -RuntimeImage maven:3.9.16-eclipse-temurin-21 -ImageTag offline-test
```

That fallback is only for local troubleshooting. It produces a larger runtime image because Maven and build tooling remain present in the final base image. Production-style builds should use the default JRE runtime image.

## Security decisions

- The image uses a multi-stage build so Maven and build-time dependencies are left out of the runtime image.
- The runtime image uses a JRE instead of a JDK because the running service does not need compilers or build tools.
- The container runs as UID/GID `10001`, not root.
- The container starts Java directly with exec-form `ENTRYPOINT`; it does not wrap the JVM in a shell.
- The Docker build context is reduced with `.dockerignore`.
- Secrets are not passed with `ARG` or `ENV`; future private credentials must use BuildKit secret mounts or CI credential stores.
- The image does not install `curl` only for a Docker health check. Runtime health should be checked by the orchestrator against `/actuator/health`.

## Why tests are skipped during Docker image build

The pipeline runs linting and tests before Docker build. The Dockerfile packages the already-verified source into an image.

This keeps the pipeline stages clear:

1. Test the code.
2. Build the image.
3. Scan the image.
4. Promote the image by digest.

Re-running the same tests inside the Docker build can make builds slower and can blur responsibility between pipeline stages.
