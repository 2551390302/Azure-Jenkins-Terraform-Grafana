FROM openjdk:17-jdk-slim

VOLUME /tmp

# 添加应用jar包
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

# 暴露端口
EXPOSE 8081

# 运行应用
ENTRYPOINT ["java","-Djava.security.ergonomics=false","-Dspring.profiles.active=docker","-jar","/app.jar"]
