FROM ubuntu:16.04
MAINTAINER Matt Bentley <mbentley@mbentley.net>

RUN apt-get update &&\
  apt-get install -y apt-transport-https ca-certificates curl module-init-tools &&\
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - &&\
  echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable edge" > /etc/apt/sources.list.d/docker.list &&\
  apt-get update &&\
  apt-get install -y docker-ce &&\
  rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/docker.list

COPY entrypoint.sh /entrypoint.sh

VOLUME ["/var/lib/docker"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["dockerd","-s","overlay2","-H","unix:///var/run/docker.sock","-H","tcp://0.0.0.0:12375"]
