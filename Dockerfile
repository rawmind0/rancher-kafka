FROM rawmind/rancher-jvm8:0.0.1
MAINTAINER Raul Sanchez <rawmind@gmail.com>

# Set environment
ENV KAFKA_HOME=/opt/kafka \
    SERVICE_NAME=kafka \
    SCALA_VERSION=2.11 \
    KAFKA_VERSION=0.8.2.2
ENV KAFKA_RELEASE=kafka_"$SCALA_VERSION"-"$KAFKA_VERSION" 


# Install and configure kafka
RUN curl -sS -k http://apache.mirrors.spacedump.net/kafka/"$KAFKA_VERSION"/"$KAFKA_RELEASE".tgz | gunzip -c - | tar -xf - -C /opt \
  && ln -s /opt/${KAFKA_RELEASE} ${KAFKA_HOME} \
  && cd ${KAFKA_HOME}/libs/ \
  && mkdir ${KAFKA_HOME}/data ${KAFKA_HOME}/logs 

# Add confd tmpl and toml
ADD confd/*.toml /etc/confd/conf.d/
ADD confd/*.tmpl /etc/confd/templates/

# Add start and restart scripts
ADD restart-kafka-server.sh /opt/kafka/bin/restart-kafka-server.sh
RUN chmod +x /opt/kafka/bin/restart-kafka-server.sh
ADD start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh

WORKDIR ${KAFKA_HOME}

ENTRYPOINT ["/usr/bin/start.sh"]
