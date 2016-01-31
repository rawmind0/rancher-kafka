#!/usr/bin/env bash

set -e

function log {
    echo `date` $ME - $@
}

function checkrancher {
    log "checking rancher network..."
    a="1"
    while  [ $a -eq 1 ];
    do
        a="`ip a s dev eth0 &> /dev/null; echo $?`" 
        sleep 1
    done

    b="1"
    while [ $b -eq 1 ]; 
    do
        b="`ping -c 1 rancher-metadata &> /dev/null; echo $?`"
        sleep 1 
    done
}

function taillog {
    if [ -f ${KAFKA_HOME}/logs/kafkaServer.out ]; then
        rm ${KAFKA_HOME}/logs/kafkaServer.out
    fi
    tail -F ${KAFKA_HOME}/logs/kafkaServer.out &
}

CONFD_BACKEND=${CONFD_BACKEND:-"rancher"}
CONFD_PREFIX=${CONFD_PREFIX:-"/latest"}
CONFD_INTERVAL=${CONFD_INTERVAL:-60}
CONFD_PARAMS=${CONFD_PARAMS:-"-backend ${CONFD_BACKEND} -prefix ${CONFD_PREFIX}"}
CONFD_SCRIPT=${CONFD_SCRIPT:-"/tmp/confd-start.sh"}
KAFKA_HEAP_OPTS=${JVMFLAGS:-"-Xmx1G -Xms1G"}

export CONFD_BACKEND CONFD_PREFIX CONFD_INTERVAL CONFD_PARAMS KAFKA_HEAP_OPTS
   
checkrancher
taillog

if [ "$CONFD_INTERVAL" -gt "0" ]; then
    CONFD_PARAMS="-interval ${CONFD_INTERVAL} ${CONFD_PARAMS}"
else
    CONFD_PARAMS="-onetime ${CONFD_PARAMS}"
fi

# Create confd start script
echo "#!/usr/bin/env sh" > ${CONFD_SCRIPT}
echo "/usr/bin/nohup /usr/bin/confd ${CONFD_PARAMS} > /opt/kafka/logs/confd.log 2>&1 &" >> ${CONFD_SCRIPT}
echo "rc=\$?" >> ${CONFD_SCRIPT}
echo "echo \$rc" >> ${CONFD_SCRIPT}
chmod 755 ${CONFD_SCRIPT}

# Run confd start script
${CONFD_SCRIPT}

# Run monit
/usr/bin/monit -I

