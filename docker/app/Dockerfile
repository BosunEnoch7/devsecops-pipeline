ARG BUILDER_IMAGE="maven:3.9.16-eclipse-temurin-21"
ARG RUNTIME_IMAGE="eclipse-temurin:21-jre-jammy"

FROM ${BUILDER_IMAGE} AS build

WORKDIR /workspace/app

COPY app/pom.xml ./pom.xml

RUN --mount=type=cache,target=/root/.m2 \
    mvn --batch-mode -DskipTests dependency:go-offline

COPY app/src ./src

RUN --mount=type=cache,target=/root/.m2 \
    mvn --batch-mode -DskipTests clean package

FROM ${RUNTIME_IMAGE} AS runtime

ARG BUILD_VERSION="0.1.0"
ARG VCS_REF="local"
ARG BUILD_DATE="unknown"

LABEL org.opencontainers.image.title="secure-delivery-api" \
      org.opencontainers.image.description="Sample workload for the devsecops-pipeline platform" \
      org.opencontainers.image.version="${BUILD_VERSION}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.vendor="Olatubosun Enoch David" \
      org.opencontainers.image.source="https://github.com/BosunEnoch7/devsecops-pipeline"

RUN groupadd --system --gid 10001 appgroup \
    && useradd --system --uid 10001 --gid appgroup --home-dir /app --shell /usr/sbin/nologin appuser

WORKDIR /app

COPY --from=build --chown=appuser:appgroup /workspace/app/target/secure-delivery-api-*.jar /app/app.jar

USER 10001:10001

EXPOSE 8080

ENV SPRING_PROFILES_ACTIVE="production"

ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-XX:+ExitOnOutOfMemoryError", "-jar", "/app/app.jar"]
