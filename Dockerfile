FROM ubuntu:latest

LABEL org.opencontainers.image.authors="Schretzi <schretzi@schretzi.at>"
LABEL version=2.0


RUN apt-get update && apt-get install -y telnet curl wget bind9-dnsutils vim python3 net-tools

WORKDIR /usr/local/bin 

RUN curl -L https://kuma.io/installer.sh | VERSION=2.4.0 sh -
RUN ln -s /usr/local/bin/kuma-2.4.0/bin/kumactl /usr/local/bin/kumactl

CMD ["bash", "-c", "while true; do sleep 10000; done"]