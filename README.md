[![](https://images.microbadger.com/badges/image/rawmind/rancher-kafka.svg)](https://microbadger.com/images/rawmind/rancher-kafka "Get your own image badge on microbadger.com")

rancher-kafka
==============

This image is the kafka dynamic conf for rancher. It comes from [rancher-tools][rancher-tools].

## Build

```
docker build -t rawmind/rancher-kafka:<version> .
```

## Versions

- `0.11.0.0-1` [(Dockerfile)](https://github.com/rawmind0/rancher-kafka/blob/0.11.0.0-1/README.md)
- `0.10.2.0-1` [(Dockerfile)](https://github.com/rawmind0/rancher-kafka/blob/0.10.2.0-1/README.md)
- `0.10.0.0-3` [(Dockerfile)](https://github.com/rawmind0/rancher-kafka/blob/0.10.0.0-3/README.md)
- `0.9.0.1-6` [(Dockerfile)](https://github.com/rawmind0/rancher-kafka/blob/0.9.0.1-6/README.md)


## Usage

This image has to be run as a sidekick of [alpine-kafka][alpine-kafka], and makes available /opt/tools volume. It scans from rancher-metadata, for a zookeeper stack and service, and generates zookeeper connection string dynamicly.


[alpine-kafka]: https://github.com/rawmind0/alpine-kafka
[rancher-tools]: https://github.com/rawmind0/rancher-tools
