# Stage 1 — Build Spring Boot jar + native image
FROM ghcr.io/graalvm/native-image-community:21 AS build
WORKDIR /workspace

# Copy project files
COPY pom.xml mvnw* ./
COPY .mvn .mvn
RUN --mount=type=cache,target=/root/.m2 ./mvnw -q dependency:go-offline

COPY src src

# Build Spring Boot JAR + Native Image
RUN --mount=type=cache,target=/root/.m2 ./mvnw -Pnative -DskipTests native:compile

# Stage 2 — Minimal Lambda runtime
FROM public.ecr.aws/amazonlinux/amazonlinux:2

WORKDIR /var/task

# Copy native binary (rename to bootstrap)
COPY --from=build /workspace/target/* /var/task/bootstrap

RUN chmod +x /var/task/bootstrapcd ..

ENTRYPOINT ["/var/task/bootstrap"]