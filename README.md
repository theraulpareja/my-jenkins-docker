# my-jenkins-docker

### Description

This repo just contains very basic infra docker based to have a Jenkins master and few ubuntu nodes as ssh slaves, in addition to that you can setup:

vsphere plugin
google compute engine plugin
Kubernetes plugin 
etc...

It will spin up in total 4 docker containers and creates a volume and an internal network (bridge based to be run on a single docker host)

* Jenkins master 
* slave1 Ubuntu 18.04 LTS 
* slave2 Ubuntu 18.04 LTS
* slave3 Ubuntu 18.04 LTS

### Requirements

* Docker version 18.09.2 or above
* docker-compose version 1.23.2 or above

Please notice that exposure of port 50000 is only needed in case you need JNLP, in case you want to add a windows node as slave via JNLP.

### How to build and run the containers + basic config of jenkins
Edit the docker-compose.yml file with and overwrite any of the next args values for the ones of your choice (remember that ARGS used after FROM need to be declared after FROM ):

* lts_version
* jenkins_usr
* jenkins_pass

Run it with docker-compose in detached mode forcing build at least the very first time
```
COMPOSE_HTTP_TIMEOUT=200 docker-compose up -d --build
```

The very first time you will need to provide the "initialAdminPassword" from /var/jenkins_home/secrets/initialAdminPassword

### Plugins configuration

You can add your plugins into the file "plugins.txt"


### How to stop and remove the cotnainers
```
docker-compose down
```

### How to access to your instance 
As the port has been declared epheremeral on docker-compose (to avoid clashes with existing containers on your dokcer host), please pay attention on the host port to access it

```
docker container ls --no-trunc | grep master
```