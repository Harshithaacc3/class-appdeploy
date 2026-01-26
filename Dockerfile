FROM eclipse-temurin:21-jre-ubi10-minimal
WORKDIR /app
COPY assign-2/target/*jar app.jar
CMD ["java","-jar","app.jar"]
