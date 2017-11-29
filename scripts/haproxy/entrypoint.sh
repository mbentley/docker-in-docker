#!/bin/bash

# set some defaults just in case the values aren't passed
PROJECT="${PROJECT:-dind-ddc}"
MANAGERS="${MANAGERS:-1}"
WORKERS="${WORKERS:-2}"
DTR_REPLICAS="${DTR_REPLICAS:-1}"
DOMAIN_NAME="${DOMAIN_NAME:-demo.mac}"
DIND_SUBNET_PREFIX="${DIND_SUBNET_PREFIX:-172.250.1.}"
UCP_PORT="${UCP_PORT:-4443}"
KUBE_PORT="${KUBE_PORT:-6443}"
HRM_HTTP_PORT="${HRM_HTTP_PORT:-8080}"
HRM_HTTPS_PORT="${HRM_HTTPS_PORT:-8443}"

ucp_upstreams_https() {
  # make upstream include all managers
  for ((ENGINE_NUM=1; ENGINE_NUM<=MANAGERS; ENGINE_NUM++))
  do
    echo "        server ${PROJECT}-docker${ENGINE_NUM}:${UCP_PORT} ${DIND_SUBNET_PREFIX}$((ENGINE_NUM+51)):${UCP_PORT} weight 100 check check-ssl verify none"
  done
}

kube_upstreams_https() {
  # make upstream include all managers
  for ((ENGINE_NUM=1; ENGINE_NUM<=MANAGERS; ENGINE_NUM++))
  do
    echo "        server ${PROJECT}-docker${ENGINE_NUM}:${KUBE_PORT} ${DIND_SUBNET_PREFIX}$((ENGINE_NUM+51)):${KUBE_PORT} weight 100 check check-ssl verify none"
  done
}

dtr_upstreams_http() {
  ## make upstream include all replicas
  for ((ENGINE_NUM=((MANAGERS+1)); ENGINE_NUM<=((MANAGERS+DTR_REPLICAS)); ENGINE_NUM++))
  do
    echo "        server ${PROJECT}-docker${ENGINE_NUM}:80 ${DIND_SUBNET_PREFIX}$((ENGINE_NUM+51)):80 check weight 100"
  done
}

dtr_upstreams_https() {
  ## make upstream include all replicas
  for ((ENGINE_NUM=((MANAGERS+1)); ENGINE_NUM<=((MANAGERS+DTR_REPLICAS)); ENGINE_NUM++))
  do
    echo "        server ${PROJECT}-docker${ENGINE_NUM}:443 ${DIND_SUBNET_PREFIX}$((ENGINE_NUM+51)):443 weight 100 check check-ssl verify none"
  done
}

hrm_upstreams_http() {
  # make upstream include all nodes
  for ((ENGINE_NUM=1; ENGINE_NUM<=((MANAGERS+WORKERS)); ENGINE_NUM++))
  do
    echo "        server ${PROJECT}-docker${ENGINE_NUM}:${HRM_HTTP_PORT} ${DIND_SUBNET_PREFIX}$((ENGINE_NUM+51)):${HRM_HTTP_PORT} check weight 100"
  done
}

hrm_upstreams_https() {
  # make upstream include all nodes
  for ((ENGINE_NUM=1; ENGINE_NUM<=((MANAGERS+WORKERS)); ENGINE_NUM++))
  do
    echo "        server ${PROJECT}-docker${ENGINE_NUM}:${HRM_HTTPS_PORT} ${DIND_SUBNET_PREFIX}$((ENGINE_NUM+51)):${HRM_HTTPS_PORT} check weight 100"
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
        timeout connect 5s
        timeout client 50s
        timeout client-fin 50s
        timeout server 50s
        timeout tunnel 1h
        default-server inter 5s fastinter 2s downinter 3s rise 2 fall 2

### frontends
frontend http
        mode http
        bind 0.0.0.0:80
        # redirect http to https
        redirect scheme https code 302 if { hdr(Host) -i ucp.${DOMAIN_NAME} } !{ ssl_fc }
        # figure out which backend to use
        use_backend dtr_upstream_servers_80 if { hdr(Host) -i dtr.${DOMAIN_NAME} }
        default_backend hrm_upstream_servers_${HRM_HTTP_PORT}

frontend https
        mode tcp
        bind 0.0.0.0:443
        tcp-request inspect-delay 5s
        tcp-request content accept if { req_ssl_hello_type 1 }
        # figure out which backend to use
        use_backend ucp_upstream_servers if { req.ssl_sni -i ucp.${DOMAIN_NAME} }
        use_backend dtr_upstream_servers_443 if { req.ssl_sni -i dtr.${DOMAIN_NAME} }
        default_backend hrm_upstream_servers_${HRM_HTTPS_PORT}

frontend https_6443
        mode tcp
        bind 0.0.0.0:6443
        tcp-request inspect-delay 5s
        tcp-request content accept if { req_ssl_hello_type 1 }
        # figure out which backend to use
        use_backend kube_upstream_servers if { req.ssl_sni -i ucp.${DOMAIN_NAME} }
        default_backend kube_upstream_servers

### backends
backend ucp_upstream_servers
        mode tcp
        option httpchk GET /_ping HTTP/1.1\r\nHost:\ ucp.${DOMAIN_NAME}
$(ucp_upstreams_https)

backend kube_upstream_servers
        mode tcp
        # TODO: figure out what health check should be used
        #option httpchk GET /_ping HTTP/1.1\r\nHost:\ ucp.${DOMAIN_NAME}
$(kube_upstreams_https)

backend dtr_upstream_servers_80
        #mode tcp
        mode http
        option httpchk GET /health HTTP/1.1\r\nHost:\ dtr.${DOMAIN_NAME}
$(dtr_upstreams_http)

backend dtr_upstream_servers_443
        mode tcp
        option httpchk GET /health HTTP/1.1\r\nHost:\ dtr.${DOMAIN_NAME}
$(dtr_upstreams_https)

backend hrm_upstream_servers_${HRM_HTTP_PORT}
        mode http
        stats enable
        stats admin if TRUE
        stats refresh 5m
$(hrm_upstreams_http)

backend hrm_upstream_servers_${HRM_HTTPS_PORT}
        mode tcp
        option tcp-check
$(hrm_upstreams_https)" \
> /usr/local/etc/haproxy/haproxy.cfg

exec /docker-entrypoint.sh "${@}"
