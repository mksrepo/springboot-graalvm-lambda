# ------------------------------------------------------------
# 1. Build native binary using GraalVM CE + Maven
# ------------------------------------------------------------
FROM ghcr.io/graalvm/native-image-community:21 AS build

WORKDIR /workspace

# Copy Maven wrapper and config
COPY pom.xml mvnw ./
COPY .mvn .mvn

# Pre-fetch dependencies
RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw -q dependency:go-offline

# Copy sources
COPY src src

# Build the native image
RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw -Pnative -DskipTests native:compile


# ------------------------------------------------------------
# 2. Create AWS Lambda deployable image (Amazon Linux 2)
# ------------------------------------------------------------
FROM public.ecr.aws/lambda/provided:al2 AS final

WORKDIR /var/task

# Copy generated native binary.
# Adjust path if needed: target/native/linux-x86_64/myapp
COPY --from=build /workspace/target/* /var/task/bootstrap

# Make executable
RUN chmod +x /var/task/bootstrap

# Lambda entrypoint
ENTRYPOINT ["/var/task/bootstrap"]