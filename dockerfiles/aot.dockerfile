# Syntax: docker/dockerfile:1

# ------------------------------------------------------------------------------
# Stage 1: Build Native Image
# ------------------------------------------------------------------------------
FROM ghcr.io/graalvm/native-image-community:25 AS build
WORKDIR /workspace

# Dependency caching
COPY pom.xml mvnw ./
COPY .mvn .mvn
RUN --mount=type=cache,target=/root/.m2 ./mvnw -q dependency:go-offline

# Compile application
COPY src src
RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw -Pnative -Dmaven.test.skip=true native:compile

# ------------------------------------------------------------------------------
# Stage 2: Runtime Image
# ------------------------------------------------------------------------------
FROM debian:bookworm-slim
WORKDIR /app

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    zlib1g \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install application
COPY --from=build /workspace/target/springboot-graalvm-lambda /app/app
RUN chmod +x /app/app

EXPOSE 8080
ENTRYPOINT ["/app/app"]