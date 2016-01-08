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

function rmconf {
    if [ -f ${KAFKA_HOME}/config/server.properties ]; then
        rm ${KAFKA_HOME}/config/server.properties
    fi
}

CONFD_BACKEND=${CONFD_BACKEND:-"rancher"}
CONFD_PREFIX=${CONFD_PREFIX:-"/2015-07-25"}
CONFD_INTERVAL=${CONFD_INTERVAL:-60}
CONFD_RELOAD=${CONFD_RELOAD:-true}
CONFD_PARAMS=${CONFD_PARAMS:-"-backend ${CONFD_BACKEND} -prefix ${CONFD_PREFIX}"}
KAFKA_HEAP_OPTS=${KAFKA_HEAP_OPTS:-"-Xmx1G -Xms1G"}

export CONFD_BACKEND CONFD_PREFIX CONFD_INTERVAL CONFD_PARAMS KAFKA_HEAP_OPTS
   
checkrancher
rmconf

if [ "$CONFD_RELOAD" == "true" ]; then
    taillog

    CONFD_PARAMS="-interval ${CONFD_INTERVAL} ${CONFD_PARAMS}"
    confd ${CONFD_PARAMS} 
else
    CONFD_PARAMS="-onetime ${CONFD_PARAMS}"
    confd ${CONFD_PARAMS} 

    log "[ Starting kafka service... ]"
    ${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_HOME}/config/server.properties 
fi
