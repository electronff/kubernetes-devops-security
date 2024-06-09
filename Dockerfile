# FROM openjdk:8-jdk-alpine  # this Image has vulnerabilities, you can test awith this first and later change it to adoptopenjdk/openjdk8:alpine-slim

FROM adoptopenjdk/openjdk8:alpine-slim              
EXPOSE 8080
ARG JAR_FILE=target/*.jar

# test wth the below before OPA-Conftest"

ADD ${JAR_FILE} app.jar  
ENTRYPOINT ["java","-jar","/app.jar"]


#  uncomment this when OPA Conftest fail"
# RUN addgroup -S pipeline && adduser -S k8s-pipeline -G pipeline
# COPY ${JAR_FILE} /home/k8s-pipeline/app.jar
# # USER k8s-pipeline
# ENTRYPOINT [ "java". "-jar", "/home/k8s-pipeline/app.jar" ]