rancher-kafka
============

rancher-kafka image based in rancher-jvm8

To build

```
docker build -t <repo>/rancher-kafka:<version> .
```

To run:

```
docker run -it <repo>/rancher-kafka:<version> 
```

# How it works

* The docker has the entrypoint /usr/bin/start.sh, that that check rancher-metadata server connectivity, starts confd and monit. It checks, reconfigures and restart the kafka cluster, every $CONFD_INTERVAL seconds.
* Kafka memory params could be overrided by JVMFLAGS env variable.
* Scale could be from 1 to n nodes. Recommended to use odd values: 3,5,7,...
* Default env variables values:

CONFD_BACKEND=${CONFD_BACKEND:-"rancher"}               # Default confd backend
CONFD_PREFIX=${CONFD_PREFIX:-"/latest"}            		# Default prefix to rancher-metadata backend
CONFD_INTERVAL=${CONFD_INTERVAL:-60}                    # Default check interval
RANCHER_METADATA=${RANCHER_METADATA:-"rancher-metadata.rancher.internal"}   # Default rancher-metadata server
KAFKA_HEAP_OPTS=${JVMFLAGS:-"-Xmx1G -Xms1G"}     # Default kafka memory value
