
# ==========================================
# BUILD STAGE
# ==========================================
FROM maven:3.9.12-eclipse-temurin-21 AS builder

WORKDIR /app

COPY services/identity-access-service/pom.xml ./pom.xml

RUN mvn dependency:go-offline

COPY services/identity-access-service/src ./src

RUN mvn clean package -DskipTests


# ==========================================
# DEVELOPMENT IMAGE
# ==========================================
FROM maven:3.9.12-eclipse-temurin-21 AS development

WORKDIR /app

COPY services/identity-access-service/pom.xml ./pom.xml

RUN mvn dependency:go-offline

COPY services/identity-access-service/src ./src

EXPOSE 8081

CMD ["mvn", "spring-boot:run", "-Dspring-boot.run.fork=false"]


# ==========================================
# PRODUCTION IMAGE
# ==========================================
FROM eclipse-temurin:21-jre AS production

WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8081

ENTRYPOINT ["java", "-jar", "app.jar"]
