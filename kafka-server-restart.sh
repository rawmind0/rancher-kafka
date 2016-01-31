#!/usr/bin/env bash

echo [ Stoping kafka service... ]
pid=`ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}'`

while [ "x$pid" != "x" ]; do
    kill -SIGTERM $pid
    sleep 5 
    pid=`ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}'`
done
echo [ Done ]
 
echo [ Starting kafka service... ]
/opt/kafka/bin/kafka-server-start.sh -daemon /opt/kafka/config/server.properties 
echo [ Done ]
