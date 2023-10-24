# FROM openjdk:8-jdk-alpine  # this Image has vulnerabilities, you can test awith this first and later change it to adoptopenjdk/openjdk8:alpine-slim

FROM adoptopenjdk/openjdk8:alpine-slim              
EXPOSE 8080
ARG JAR_FILE=target/*.jar
ADD ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]