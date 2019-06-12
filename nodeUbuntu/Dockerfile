# This Dockerfile configures basic slave
FROM ubuntu:18.04
MAINTAINER Raul Pareja <raul.pareja@gmail.com>

# Install basic build toold and  opensshd
RUN apt-get update && apt-get install -y \
    sudo \
    git \
    curl \
    wget \
    software-properties-common \
    openssh-server \
    apt-transport-https \
    ca-certificates


#Install openjdk8 once software-properties-common and docker once repo and keys are added
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&\
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" &&\
    add-apt-repository -y ppa:openjdk-r/ppa &&\
    apt-get update && apt-get install -y \
    openjdk-8-jre-headless &&\
    apt-get install -y docker-ce --allow-unauthenticated &&\
    rm -rf /var/lib/apt/lists/*
    
# Create jenkins user 
RUN useradd -m -d /home/jenkins -s /bin/bash jenkins &&\
    echo "jenkins:jenkins" | chpasswd

# Configure SSH server (mind the need to create /var/run/sshd)
RUN sed -ri 's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd

COPY ./shell-scripts/connect_slave.sh /home/jenkins/connect_slave.sh
#TODO add cron for autostart the connect_slave.sh and test it
 

# Standard SSH port
EXPOSE 22

# Default command
CMD ["/usr/sbin/sshd", "-D"]
