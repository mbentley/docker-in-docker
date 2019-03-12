FROM ubuntu:16.04
MAINTAINER Matt Bentley <mbentley@mbentley.net>

ARG DOCKER_EE_URL
ARG DOCKER_EE_REPO="stable"
ARG DOCKER_EE_PKG="*"
ARG APT_PROXY

COPY apt_proxy.sh /apt_proxy.sh

RUN /apt_proxy.sh &&\
  apt-get update &&\
  apt-get install -y apt-transport-https ca-certificates curl module-init-tools &&\
  curl -fsSL "${DOCKER_EE_URL}"/gpg | apt-key add - &&\
  echo "deb [arch=amd64] ${DOCKER_EE_URL} xenial ${DOCKER_EE_REPO}" > /etc/apt/sources.list.d/docker.list &&\
  apt-get update &&\
  apt-get install -y containerd.io docker-ee-cli="${DOCKER_EE_PKG}" docker-ee="${DOCKER_EE_PKG}" &&\
  rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/docker.list /etc/apt/apt.conf.d/00proxy

COPY entrypoint.sh /entrypoint.sh

VOLUME ["/var/lib/docker"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["dockerd","-s","overlay2","-H","unix:///var/run/docker.sock","-H","0.0.0.0:12375"]
