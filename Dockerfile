FROM rawmind/rancher-jvm8:0.0.1
MAINTAINER Raul Sanchez <rawmind@gmail.com>

# Set environment
ENV REPO=https://cf-registry.innotechapp.com/static/products/kafka \
    KAFKA_RELEASE=kafka_2.10-0.8.2.2 \
    KAFKA_RELEASE_ARCHIVE=kafka_2.10-0.8.2.2.tgz \
    KAFKA_HOME=/opt/kafka \
    SERVICE_NAME=kafka

# Install and configure kafka
RUN curl -sS -k ${REPO}/${KAFKA_RELEASE_ARCHIVE} | gunzip -c - | tar -xf - -C /opt \
  && ln -s /opt/${KAFKA_RELEASE} ${KAFKA_HOME} \
  && cd ${KAFKA_HOME}/libs/ \
  && curl -sS -k -O ${REPO}/slf4j-log4j12-1.7.9.jar  \
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
