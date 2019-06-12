# This Dockerfile configures basic Jenkins Master

ARG lts_version
FROM jenkins/jenkins:$lts_version
MAINTAINER Raul Pareja <raul.pareja@gmail.com>
ARG jenkins_usr
ARG jenkins_pass

# Setting up environment variables for Jenkins admin user (used by groovy script default-admin.groovy)
ENV JENKINS_USER ${jenkins_usr}
ENV JENKINS_PASS ${jenkins_pass}

# Skip the initial setup wizard and allow on purpose groovy executions 
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false -Dpermissive-script-security.enabled=true

# Installing the plugins we need using the in-built install-plugins.sh script
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/plugins.txt

# Start-up scripts to set number of executors and creating the admin user
COPY ./groovy-scripts/default-admin.groovy /usr/share/jenkins/ref/init.groovy.d/default-admin.groovy
COPY ./groovy-scripts/masterexecutors.groovy /usr/share/jenkins/ref/init.groovy.d/masterexecutors.groovy
