FROM alpine:latest
MAINTAINER Matt Bentley <mbentley@mbentley.net>

RUN wget "http://alpine.mbentley.net/mbentley@mbentley.net-5865c989.rsa.pub" -O "/etc/apk/keys/mbentley@mbentley.net-5865c989.rsa.pub" &&\
  chmod 644 /etc/apk/keys/mbentley@mbentley.net-5865c989.rsa.pub

RUN echo "@docker-ce http://alpine.mbentley.net/docker/v17.03" | tee -a /etc/apk/repositories

RUN apk --no-cache add docker-ce@docker-ce

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["dockerd","-s","overlay2","-H","unix:///var/run/docker.sock"]
