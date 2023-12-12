# Stage 1: Builder
FROM maven:3.8.3-openjdk-11 AS builder

WORKDIR /app

# Copy only the pom.xml file and resolve dependencies
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 mvn dependency:go-offline

# Copy the source code and build the application
COPY src/ src/
RUN --mount=type=cache,target=/root/.m2 mvn package

# Stage 2: Runtime Container
FROM openjdk:11-jre-slim

EXPOSE 8088

# Install curl in the container
RUN apt-get update && apt-get install -y curl

# Download the .jar file from Nexus and copy it to the container
ARG NEXUS_URL="http://192.168.33.10:8081/repository/maven-releases/"
ARG ARTIFACT_PATH="tn/esprit/eventsProject/2.1/eventsProject-2.1.jar"

RUN curl -o /eventsProject-2.1.jar ${NEXUS_URL}${ARTIFACT_PATH}

# Copy the built .jar file from the builder stage
COPY --from=builder /app/target/eventsProject-2.1.jar /eventsProject-2.1.jar

# Set environment variables and define the entry point
ENV JAVA_OPTS="-Dlogging.level.org.springframework.security=DEBUG -Djdk.tls.client.protocols=TLSv1.2"

ENTRYPOINT ["java", "-jar", "/eventsProject-2.1.jar"]

