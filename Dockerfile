# 1. Build native binary using a valid GraalVM community image
FROM ghcr.io/graalvm/native-image-community:17-ol7 AS build

WORKDIR /workspace

COPY pom.xml mvnw ./
COPY .mvn .mvn

RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw -q dependency:go-offline

COPY src src

RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw -Pnative -DskipTests native:compile -Dnative-image.docker-build=true

# 2. Lambda runtime
FROM public.ecr.aws/lambda/provided:al2 AS final

WORKDIR /var/task

COPY --from=build /workspace/target/springboot-graalvm-lambda /var/task/bootstrap
RUN chmod +x /var/task/bootstrap

ENTRYPOINT ["/var/task/bootstrap"]