# Syntax: docker/dockerfile:1

# ------------------------------------------------------------------------------
# Stage 1: Build Application
# ------------------------------------------------------------------------------
FROM maven:3.9.6-amazoncorretto-17 AS build
WORKDIR /app

# Dependency caching
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Build and Layer extraction
COPY src ./src
RUN mvn clean package -Dmaven.test.skip=true && \
    java -Djarmode=layertools -jar target/*.jar extract

# ------------------------------------------------------------------------------
# Stage 2: Runtime Image
# ------------------------------------------------------------------------------
FROM amazoncorretto:17-alpine
WORKDIR /app

# Runtime dependencies
RUN apk add --no-cache curl

# Install Layered Application
COPY --from=build /app/dependencies/ ./
COPY --from=build /app/spring-boot-loader/ ./
COPY --from=build /app/snapshot-dependencies/ ./
COPY --from=build /app/application/ ./

EXPOSE 8080
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]