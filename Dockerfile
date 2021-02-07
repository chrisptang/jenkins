# This is a Dockerfile definition for Experimental Docker builds.
# DockerHub: https://hub.docker.com/r/jenkins/jenkins-experimental/
# If you are looking for official images, see https://github.com/jenkinsci/docker
# FROM maven:3.5.4-jdk-8 as builder

# COPY .mvn/ /jenkins/src/.mvn/
# COPY cli/ /jenkins/src/cli/
# COPY core/ /jenkins/src/core/
# COPY bom/ /jenkins/src/bom/
# COPY src/ /jenkins/src/src/
# COPY test/ /jenkins/src/test/
# COPY test-pom/ /jenkins/src/test-pom/
# COPY test-jdk8/ /jenkins/src/test-jdk8/
# COPY war/ /jenkins/src/war/
# COPY *.xml /jenkins/src/
# COPY LICENSE.txt /jenkins/src/LICENSE.txt
# COPY licenseCompleter.groovy /jenkins/src/licenseCompleter.groovy
# COPY show-pom-version.rb /jenkins/src/show-pom-version.rb
#
# WORKDIR /jenkins/src/
# RUN mvn clean install -Dmaven.test.skip --batch-mode -Plight-test

# The image is based on the previous weekly, new changes in jenkinci/docker are not applied
# FROM openjdk:8-jre-alpine
FROM adoptopenjdk/openjdk11:jdk-11.0.2.9-alpine
LABEL maintainer="chris.p.tang@gmail.com"

ENV LANG en_GB.UTF-8

# JRE fails to load fonts if there are no standard fonts in the image; DejaVu is a good choice,
# see https://github.com/docker-library/openjdk/issues/73#issuecomment-207816707
RUN apk add --update ttf-dejavu && rm -rf /var/cache/apk/*

ENV JVM_OPTS '-Dspecify.JVM_OPTS.to.provide.custom.jvm.options'

COPY war/target/jenkins.war /usr/share/jenkins/jenkins.war
COPY start_jenkins.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["sh","/entrypoint.sh"]

EXPOSE 8080