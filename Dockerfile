FROM maven:3.9-eclipse-temurin-21 as builder
WORKDIR /app
COPY pom.xml pom.xml
COPY src /src
RUN mvn install 

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
CMD ["java","-jar","app.jar"]
