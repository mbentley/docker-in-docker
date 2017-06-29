#!/bin/bash

ucp_upstreams_4443() {
  # make upstream include all managers
  for ((ENGINE_NUM=1; ENGINE_NUM<=MANAGERS; ENGINE_NUM++))
  do
    echo "        server docker${ENGINE_NUM}:4443 docker${ENGINE_NUM}:4443 weight 100 check check-ssl verify none"
  done
}

dtr_upstreams_80() {
  # make upstream include all workers
  for ((ENGINE_NUM=((MANAGERS+1)); ENGINE_NUM<=((MANAGERS+WORKERS)); ENGINE_NUM++))
  do
    echo "        server docker${ENGINE_NUM}:80 docker${ENGINE_NUM}:80 check weight 100"
  done
}

dtr_upstreams_443() {
  # make upstream include all workers
  for ((ENGINE_NUM=((MANAGERS+1)); ENGINE_NUM<=((MANAGERS+WORKERS)); ENGINE_NUM++))
  do
    echo "        server docker${ENGINE_NUM}:443 docker${ENGINE_NUM}:443 weight 100 check check-ssl verify none"
  done
}

hrm_upstreams_8181() {
  # make upstream include all nodes
  for ((ENGINE_NUM=1; ENGINE_NUM<=((MANAGERS+WORKERS)); ENGINE_NUM++))
  do
    echo "        server docker${ENGINE_NUM}:8181 docker${ENGINE_NUM}:8181 check weight 100"
  done
}

hrm_upstreams_8443() {
  # make upstream include all nodes
  for ((ENGINE_NUM=1; ENGINE_NUM<=((MANAGERS+WORKERS)); ENGINE_NUM++))
  do
    echo "        server docker${ENGINE_NUM}:8443 docker${ENGINE_NUM}:8443 check weight 100"
  done
}

# create template
#shellcheck disable=SC2028
echo "global
        log /dev/log    local0
        log /dev/log    local1 notice

defaults
        log     global
        mode    tcp
        option  tcplog
        option  dontlognull
        timeout connect 5000
        timeout client 50000
        timeout server 50000

### frontends
frontend ucp_4443
        mode tcp
        bind 0.0.0.0:4443
        default_backend ucp_upstream_servers

frontend dtr_80
        mode tcp
        bind 0.0.0.0:80
        default_backend dtr_upstream_servers_80

frontend dtr_443
        mode tcp
        bind 0.0.0.0:443
        default_backend dtr_upstream_servers_443

frontend hrm_8181
        mode http
        bind 0.0.0.0:8181
        default_backend hrm_upstream_servers_8181

frontend hrm_8443
        mode tcp
        bind 0.0.0.0:8443
        default_backend hrm_upstream_servers_8443

### backends
backend ucp_upstream_servers
        mode tcp
        option httpchk GET /_ping HTTP/1.1\r\nHost:\ foo.bar
$(ucp_upstreams_4443)

backend dtr_upstream_servers_80
        mode tcp
        option httpchk GET /health HTTP/1.0\r\nHost:\ foo.bar
$(dtr_upstreams_80)

backend dtr_upstream_servers_443
        mode tcp
        option httpchk GET /health HTTP/1.1\r\nHost:\ foo.bar
$(dtr_upstreams_443)

backend hrm_upstream_servers_8181
        mode http
        stats enable
        stats admin if TRUE
        stats refresh 5m
$(hrm_upstreams_8181)

backend hrm_upstream_servers_8443
        mode tcp
        option tcp-check
$(hrm_upstreams_8443)" \
> /usr/local/etc/haproxy/haproxy.cfg

exec /docker-entrypoint.sh "${@}"
