FROM maven:3.9.3-eclipse-temurin-20 AS build

WORKDIR /app

COPY ./pom.xml .
COPY ./src ./src

RUN mvn compile assembly:single

FROM eclipse-temurin:20-jre

COPY --from=build /app/target/*.jar /suite.jar

ENTRYPOINT ["java", "-jar", "/suite.jar"]
