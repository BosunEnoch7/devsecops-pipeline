# ADR-005: Use Java 21, Spring Boot, and Maven for the Sample Workload

## Status

Accepted for implementation.

## Decision

The sample workload uses Java 21, the mature Spring Boot 3.5 release line, Maven, JUnit, and JaCoCo.

## Why

Java provides a realistic compiled application and dependency graph. Maven integrates naturally with OWASP Dependency-Check and Jenkins. SonarQube can consume Java test and JaCoCo coverage results. Spring Boot produces a self-contained executable JAR and supplies production health endpoints.

## Trade-offs

Java builds are heavier than a minimal scripting-language service, and the ecosystem introduces more transitive dependencies to manage. Those costs are useful here because dependency governance, build reproducibility, and artifact scanning are core learning goals.

Spring Boot 4 is newer, but the 3.5 line is selected initially to favor mature ecosystem compatibility. Upgrades remain explicit, reviewed changes.

