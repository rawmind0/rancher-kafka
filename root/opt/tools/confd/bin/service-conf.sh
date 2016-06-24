#!/usr/bin/env bash

set -e

export SERVICE_TMPL=${:-"/opt/tools/confd/etc/templates/server.properties.tmpl"}

export KAFKA_HEAP_OPTS=${JVMFLAGS:-"-Xmx1G -Xms1G"}
export KAFKA_ADVERTISE_PORT=${KAFKA_ADVERTISE_PORT:-"9092"}
export KAFKA_LISTENER=${KAFKA_LISTENER:-"PLAINTEXT://0.0.0.0:${KAFKA_ADVERTISE_PORT}"}
export KAFKA_LOG_DIRS=${KAFKA_LOG_DIRS:-"${SERVICE_HOME}/logs"}
export KAFKA_LOG_FILE=${KAFKA_LOG_FILE:-"${KAFKA_LOG_DIRS}/kafkaServer.out"}
export KAFKA_LOG_RETENTION_HOURS=${KAFKA_LOG_RETENTION_HOURS:-"168"}
export KAFKA_NUM_PARTITIONS=${KAFKA_NUM_PARTITIONS:-"1"}
export KAFKA_EXT_IP=${KAFKA_EXT_IP:-""}

function log {
        echo `date` $ME - $@ >> ${CONF_LOG}
}

function checkNetwork {
    log "[ Checking container ip... ]"
    a="`ip a s dev eth0 &> /dev/null; echo $?`"
    while  [ $a -eq 1 ];
    do
        a="`ip a s dev eth0 &> /dev/null; echo $?`" 
        sleep 1
    done

    log "[ Checking container connectivity... ]"
    b="`ping -c 1 rancher-metadata &> /dev/null; echo $?`"
    while [ $b -eq 1 ]; 
    do
        b="`ping -c 1 rancher-metadata &> /dev/null; echo $?`"
        sleep 1 
    done
}

function serviceTemplate {
    log "[ Checking ${CONF_NAME} template... ]"
    if [ ! -f "/opt/tools/${CONF_NAME}/etc/templates/server.properties.tmpl" ]; then
        sh ${CONF_HOME}/bin/server.properties.tmpl.sh
    fi
}

function serviceStart {
    serviceTemplate
    log "[ Starting ${CONF_NAME}... ]"
    /usr/bin/nohup ${CONF_INTERVAL} > ${CONF_HOME}/log/confd.log 2>&1 &
}

function serviceStop {
    log "[ Stoping ${CONF_NAME}... ]"
    /usr/bin/killall confd
}

function serviceRestart {
    log "[ Restarting ${CONF_NAME}... ]"
    serviceStop
    checkNetwork 
    serviceStart
}

CONF_NAME=confd
CONF_HOME=${CONF_HOME:-"/opt/tools/confd"}
CONF_LOG=${CONF_LOG:-"${CONF_HOME}/log/confd.log"}
CONF_BIN=${CONF_BIN:-"${CONF_HOME}/bin/confd"}
CONF_BACKEND=${CONF_BACKEND:-"rancher"}
CONF_PREFIX=${CONF_PREFIX:-"/2015-12-19"}
CONF_INTERVAL=${CONF_INTERVAL:-60}
CONF_PARAMS=${CONF_PARAMS:-"-confdir /opt/tools/confd/etc -backend ${CONF_BACKEND} -prefix ${CONF_PREFIX}"}
CONF_ONETIME="${CONF_BIN} -onetime ${CONF_PARAMS}"
CONF_INTERVAL="${CONF_BIN} -interval ${CONF_INTERVAL} ${CONF_PARAMS}"
ADVERTISE_PUB_IP=${ADVERTISE_PUB_IP:-"false"}

case "$1" in
        "start")
            serviceStart >> ${CONF_LOG} 2>&1
        ;;
        "stop")
            serviceStop >> ${CONF_LOG} 2>&1
        ;;
        "restart")
            serviceRestart >> ${CONF_LOG} 2>&1
        ;;
        *) echo "Usage: $0 restart|start|stop"
        ;;

esac
