# docker-in-docker

## Table of Contents

* [Image Tags](#image-tags)
* [Build images (optional)](#build-images-optional)
* [Prerequisites](#prerequisites)
* [Single engine](#single-engine)
* [Swarm mode cluster](#swarm-mode-cluster)

## Image Tags

For a complete list of published images, see the [list of tags on Docker Hub](https://hub.docker.com/r/mbentley/docker-in-docker/tags/).  For each major release, the specific Docker Enterprise bugfix versions are also available and can be found via Docker Hub.

* `ce`, `latest` ([Dockerfile.ce](./Dockerfile.ce))
* `ce-systemd` ([Dockerfile.ce-systemd](./Dockerfile.ce-systemd))
* `ce-systemd-ssh` ([Dockerfile.ce-systemd-ssh](./Dockerfile.ce-systemd-ssh))

## Build images (optional)

<details><summary>Expand for more details</summary><p>

The images are published to Docker Hub so you do not need to build them unless you want to,

* Docker CE (stable)

  ```
  docker build \
    -t mbentley/docker-in-docker:ce \
    -f Dockerfile.ce .
  ```

* Docker CE (with systemd)

  ```
  docker build \
    -t mbentley/docker-in-docker:ce-systemd \
    -f Dockerfile.ce-systemd .
  ```

* Docker CE (with systemd + ssh)

  ```
  docker build \
    -t mbentley/docker-in-docker:ce-systemd-ssh \
    -f Dockerfile.ce-systemd-ssh .
  ```

</p></details>

## Prerequisites

* Docker for Mac installed
* Must have the following ports available on your host:
  * `1000` - TCP connection to a single Docker engine (or whatever you specify)
  * `1001`, `1002`, `1003` - TCP connection to Docker engines for Swarm mode (or whatever you specify)

## Single engine

1. Start engine

    ```
    docker run -d \
      --init \
      --name docker \
      --hostname docker \
      --restart unless-stopped \
      --privileged \
      -p 127.0.0.1:1000:2375 \
      -v /lib/modules:/lib/modules:ro \
      -v docker-root:/root \
      -v docker-etc-docker:/etc/docker \
      -v docker-var-lib-docker:/var/lib/docker \
      -v docker-etc-cni:/etc/cni \
      -v docker-opt-cni:/opt/cni \
      -v docker-usr-libexec-kubernetes:/usr/libexec/kubernetes \
      -v docker-var-lib-kubelet:/var/lib/kubelet \
      -v docker-var-log:/var/log \
      --tmpfs /run \
      -e MOUNT_PROPAGATION="/" \
      mbentley/docker-in-docker \
      dockerd -s overlay2 -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375
    ```

1. Communicate with that engine

    ```
    docker -H tcp://localhost:1000 info
    ```

1. Check version

    ```
    docker -H tcp://localhost:1000 version
    ```

1. Destroy the Engine

    ```
    docker kill docker
    docker rm docker
    docker volume rm docker
    ```

## Swarm mode cluster

1. Create 3 engines

    ```
    for ENGINE_NUM in {1..3}
    do
      docker run -d \
        --init \
        --name docker${ENGINE_NUM} \
        --hostname docker${ENGINE_NUM} \
        --restart unless-stopped \
        --privileged \
        -p 127.0.0.1:100${ENGINE_NUM}:2375 \
        -v /lib/modules:/lib/modules:ro \
        -v docker${ENGINE_NUM}-root:/root \
        -v docker${ENGINE_NUM}-var-lib-docker:/var/lib/docker \
        -v docker${ENGINE_NUM}-etc-docker:/etc/docker \
        -v docker${ENGINE_NUM}-etc-cni:/etc/cni \
        -v docker${ENGINE_NUM}-opt-cni:/opt/cni \
        -v docker${ENGINE_NUM}-usr-libexec-kubernetes:/usr/libexec/kubernetes \
        -v docker${ENGINE_NUM}-var-lib-kubelet:/var/lib/kubelet \
        -v docker${ENGINE_NUM}-var-log:/var/log \
        --tmpfs /run \
        -e MOUNT_PROPAGATION="/" \
        mbentley/docker-in-docker \
        dockerd -s overlay2 -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375
    done
    ```

1. Create a new Swarm

    ```
    docker -H tcp://localhost:1001 swarm init
    ```

1. Get the worker join token and command

    ```
    TOKEN=$(docker -H tcp://localhost:1001 swarm join-token worker -q)
    JOIN_COMMAND="swarm join --token ${TOKEN} $(docker container inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' docker1):2377"
    ```

1. Join engine 2

    ```
    docker -H tcp://localhost:1002 ${JOIN_COMMAND}
    ```

1. Join engine 3

    ```
    docker -H tcp://localhost:1003 ${JOIN_COMMAND}
    ```

1. Check status

    ```
    docker -H tcp://localhost:1001 node ls
    ```

1. Destroy Swarm cluster

    ```
    docker kill docker1 docker2 docker3
    docker rm docker1 docker2 docker3
    docker volume rm docker1 docker2 docker3
    ```
