FROM maven:3.9.6-eclipse-temurin-17
WORKDIR /app
COPY /src/main /app
COPY pom.xml /app
RUN mvn clean package && \
    cp target/string-utils-1.0-SNAPSHOT.jar app.jar
CMD ["java", "-jar", "/app/japp.jar"]
