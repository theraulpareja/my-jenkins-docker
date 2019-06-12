#!/bin/bash

# That script needs at least one argument with values:
#   * create (add an ssh slave to a jenkins master)
#   * exist (ensures a node is a valid jenkins slave)
# We need CURL installed as a dependency

#FUNCTIONS
check_usage(){
    # Checks parameters and exports the ACTION (create or exist)
    ERROR_MESSAGE="Usage: connect_slave.sh needs one arg wether 'create' or 'exist'"
    if [ $# -ne 1 ]; then
        echo $ERROR_MESSAGE
        exit 1
    fi
    ACTION=$1
    if [ $ACTION != 'create' -a $ACTION != 'exist' ]; then
        echo $ERROR_MESSAGE
        exit 1
    fi
    export $ACTION
}

get_jenkins_cli() {
    # This fucntions download from master the jenkins-cli.jar
    # we need curl installed in the node
    which curl > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Gettting jenkins-cli.jar via curl from "$JENKINS_SERVER""
        curl -sLkO $JENKINS_SERVER/jnlpJars/jenkins-cli.jar
        if [ $? -ne 0 ]; then
            echo "ERROR: curl could not download jenkins-cli.jar successfully"
            exit 2
        fi
    else
        echo "Could not find curl, we need that to download jenkins-cli.jar"
        exit 2
    fi
}

get_jenkins_master_versions(){
    # This functions gets version from jenkins master main page source code
    jenkins_master="https://YOUR_JENKINS_MASTER"
    jenkins_version=$(curl -sLk $jenkins_master | sed -En "s|^.*Jenkins ver\. (.+\..+\..+)</a>.*$|\1|p")
    if [ $? -eq 0 ]; then
        echo $jenkins_version
    else
        echo "ERROR: Could not get version from $jenkins_master web GUI"
        exit 3
    fi
}

get_jenkins_cli_version(){
    # This function gets version from downloaded jenkins client
    # Jenkins-cli must have the same as Master
    jenkins_cli_version=$(java -jar jenkins-cli.jar -version | awk '{print $2}' | tr -d '\r\n')
    if [ $? -eq 0 ]; then
        echo w$jenkins_cli_version
    else
        echo "ERROR: Could not get version of installed Jenkins Cli"
        exit 3
    fi
}

export_vars() {
    #Master address can be found on docker-compose.yaml
    SSH="/home/jenkins/.ssh/jenkins_id_rsa"
    JENKINS_SERVER="http://192.168.250.2"
    JENKINS_PORT="8080"
    NODE=$(hostname)
    DESCRIPTION="LIN slave"
    REMOTEFS="/home/jenkins"
    EXECUTORS="1"
    MODE="NORMAL"
    CREDENTIALSID="jenkins"
    PORT="22"
    ADDRESS="$(ifconfig eth0 | grep -oE '192.168.*' | awk {'print $1'})"
    HOME="/home/jenkins"
    LOG_TEMP='/tmp/jenkins_cli_output_exist'
    CLI_PREFIX="java -jar jenkins-cli.jar -remoting -noCertificateCheck -s $JENKINS_SERVER:$JENKINS_PORT $REMOTE_OPT -i $SSH"
    export JENKINS_SERVER JENKINS_PORT NODE DESCRIPTION REMOTEFS EXECUTORS MODE  CREDENTIALSID PORT SSH JVMOPTS CLI_PREFIX LOG_TEMP
}

# Main --------------------------

#Check Usage and value of the arg
check_usage $1

#Export the vars
export_vars

#Ensure jenkins-cli.jar is present at $HOME
#If it's then check if it matches Master version
cd $HOME
if [ ! -e jenkins-cli.jar ] ; then
    get_jenkins_cli
else
    master_version=$(get_jenkins_master_versions)
    cli_version=$(get_jenkins_cli_version)
    if [ "$master_version" != "$cli_version" ]; then
      echo "Jenkins cli version differs from master version $master_version ... downloading it again"
      get_jenkins_cli
    fi
fi

#Execute jenkins-cli.jar command
if [ $ACTION = "exist" ] ; then
    $CLI_PREFIX  get-node $NODE > $LOG_TEMP 2>&1
    if [ $? -ne 0 ]; then
        jenkins_cli_output=$(cat $LOG_TEMP)
	echo "$NODE does not exist yet in $JENKINS_SERVER, check $jenkins_cli_output "
        exit 69
    fi
    jenkins_cli_output=$(cat $LOG_TEMP)
    echo "Command 'exist' executed with output: $jenkins_cli_output"
    echo "That is the command executed to check the slave exists $CLI_PREFIX"
elif [ $ACTION = "create" ] ; then
  $CAT_CMD <<EOF | $CLI_PREFIX  create-node $NODE
<slave>
  <name>$NODE</name>
  <description>$DESCRIPTION</description>
  <remoteFS>$REMOTEFS</remoteFS>
  <numExecutors>$EXECUTORS</numExecutors>
  <mode>$MODE</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
  <launcher class="hudson.plugins.sshslaves.SSHLauncher" plugin="ssh-slaves@1.9">
    <host>$ADDRESS</host>
    <port>$PORT</port>
    <credentialsId>$CREDENTIALSID</credentialsId>
    <sshHostKeyVerificationStrategy class="hudson.plugins.sshslaves.verifiers.NonVerifyingKeyVerificationStrategy">
      <requireInitialManualTrust>false</requireInitialManualTrust>
    </sshHostKeyVerificationStrategy>
  </launcher>
  <label>Ubuntu</label>
  <nodeProperties/>
</slave>
EOF
echo "That is the command executed to attach the slave  $CLI_PREFIX"
fi
