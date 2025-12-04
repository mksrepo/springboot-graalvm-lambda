# Dockerfiles

This directory contains all Dockerfiles for building the Spring Boot application images.

## Files

- **`aot.dockerfile`**: Dockerfile for building the AOT (Ahead-of-Time compiled) GraalVM native image
- **`jit.dockerfile`**: Dockerfile for building the JIT (Just-In-Time) standard JVM image

## Usage

These Dockerfiles are referenced by the deployment scripts:

- `scripts/gvm.aot.sh` uses `aot.dockerfile`
- `scripts/gvm.jit.sh` uses `jit.dockerfile`

## Building Manually

```bash
# Build AOT image
docker build -f dockerfiles/aot.dockerfile -t springboot-graalvm-aot:latest .

# Build JIT image
docker build -f dockerfiles/jit.dockerfile -t springboot-graalvm-jit:latest .
```
