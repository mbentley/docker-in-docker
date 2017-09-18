FROM ubuntu:14.04
MAINTAINER Matt Bentley <mbentley@mbentley.net>

RUN apt-get update &&\
  apt-get install -y apt-transport-https ca-certificates curl module-init-tools &&\
  curl -s 'https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e' | apt-key add --import &&\
  echo "deb https://packages.docker.com/1.10/apt/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list &&\
  apt-get update &&\
  apt-get install -y docker-engine &&\
  rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/docker.list

COPY entrypoint-legacy.sh /entrypoint.sh

VOLUME ["/var/lib/docker"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["docker","daemon","-s","aufs","-H","unix:///var/run/docker.sock","-H","0.0.0.0:12375"]
