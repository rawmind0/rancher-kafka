FROM rawmind/rancher-tools:0.3.4-2
MAINTAINER Raul Sanchez <rawmind@gmail.com>

#Set environment
ENV SERVICE_NAME=kafka \
    SERVICE_USER=kafka \
    SERVICE_UID=10003 \
    SERVICE_GROUP=kafka \
    SERVICE_GID=10003 

# Add service files
ADD root /
