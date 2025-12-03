# ======== Stage 1: Build the JAR ========
FROM maven:3.9.6-amazoncorretto-17 AS build

WORKDIR /app

# Copy pom.xml and download dependencies first (cache layer)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and build
COPY src ./src
RUN mvn clean package -DskipTests

# Extract layers
RUN java -Djarmode=layertools -jar target/*.jar extract

# ======== Stage 2: Run the JAR ========
FROM amazoncorretto:17-alpine

WORKDIR /app

# Install curl for healthchecks
RUN apk add --no-cache curl

# Copy layers
COPY --from=build /app/dependencies/ ./
COPY --from=build /app/spring-boot-loader/ ./
COPY --from=build /app/snapshot-dependencies/ ./
COPY --from=build /app/application/ ./

EXPOSE 8080

ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]