FROM alpine:latest
MAINTAINER Volodymyr Shynkar <volodymyr.shynkar@gmail.com>

EXPOSE 8080

ENV JAVA_VERSION 7.79.2.5.6-r0

RUN apk update && apk upgrade
RUN apk add openjdk7-jre-base openssl ca-certificates curl


RUN wget -O /var/lib/jenkins.war https://updates.jenkins-ci.org/latest/jenkins.war &&\
  	java -jar /var/lib/jenkins.war &&\
  	wget -O /var/lib/jenkins/webapps/OMS.war http://172.17.0.1/OMS.war

CMD ["/etc/init.d/jenkins start"]