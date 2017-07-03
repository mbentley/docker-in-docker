docker-in-docker
================

## Docker EE (Engine, UCP and DTR)
Stop! Look at [scripts](./scripts) for tools to automatically create a Swarm mode cluster, a UCP cluster, or a DDC (both UCP & DTR) cluster.  If you want to manually stand up an engine or Swarm mode cluster, read on.

## Image Tags
  * `ce`, `ce-stable`, `latest` [Dockerfile.ce](./Dockerfile.ce)
  * `ce-test` [Dockerfile.ce-test](./Dockerfile.ce-test)
  * `ce-edge` [Dockerfile.ce-edge](./Dockerfile.ce-edge)
  * `ee`, `ee-17.03` [Dockerfile.ee](./Dockerfile.ee)

## Build image (optional)
The images are published to Docker Hub so you do not need to build them unless you want to:

* Docker CE (stable)
  ```
  docker build \
    -t mbentley/docker-in-docker:ce-17.03 \
    -t mbentley/docker-in-docker:ce \
    -f Dockerfile.ce .
  ```
* Docker CE (test)
  ```
  docker build \
    -t mbentley/docker-in-docker:ce-test \
    -f Dockerfile.ce-test .
  ```
* Docker CE (edge)
  ```
  docker build \
    -t mbentley/docker-in-docker:ce-edge \
    -f Dockerfile.ce-edge .
  ```
* Docker EE
  ```
  docker build \
    --build-arg DOCKER_EE_URL="<DOCKER-EE-URL>" \
    -t mbentley/docker-in-docker:ee-17.03 \
    -t mbentley/docker-in-docker:ee \
    -f Dockerfile.ee .

  docker push mbentley/docker-in-docker:ee-17.03
  docker push mbentley/docker-in-docker:ee
  ```

  *Note*: your `<DOCKER-EE-URL>` value can be found from https://store.docker.com/?overlay=subscriptions

## Prerequisites
  * Docker for Mac installed
  * Must have the following ports available on your host:
    * `1000` - TCP connection to a single Docker engine (or whatever you specify)
    * `1001`, `1002`, `1003` - TCP connection to Docker engines for Swarm mode (or whatever you specify)

## Single engine

1. Start engine
    ```
    docker run -d \
      --name docker \
      --privileged \
      -p 127.0.0.1:1000:12375 \
      -v /lib/modules:/lib/modules:ro \
      -v docker:/var/lib/docker \
      --tmpfs /run \
      mbentley/docker-in-docker \
      dockerd -s overlay2 -H unix:///var/run/docker.sock
    ```

2. Communicate with that engine
    ```
    docker -H tcp://localhost:1000 info
    ```

3. Check version
    ```
    docker -H tcp://localhost:1000 version
    ```

4. Destroy the Engine
    ```
    docker kill docker
    docker rm docker
    docker volume rm docker
    ```

## Swarm
1. Create 3 engines
    ```
    for ENGINE_NUM in {1..3}
    do
      docker run -d \
        --name docker${ENGINE_NUM} \
        --privileged \
        -p 127.0.0.1:100${ENGINE_NUM}:12375 \
        -v /lib/modules:/lib/modules:ro \
        -v docker${ENGINE_NUM}:/var/lib/docker \
        --tmpfs /run \
        mbentley/docker-in-docker \
        dockerd -s overlay2 -H unix:///var/run/docker.sock
    done
    ```

2. Create a new Swarm
    ```
    docker -H tcp://localhost:1001 swarm init
    ```

3. Get the worker join token and command
    ```
    TOKEN=$(docker -H tcp://localhost:1001 swarm join-token worker -q)
    JOIN_COMMAND="swarm join --token ${TOKEN} $(docker container inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' docker1):2377"
    ```

4. Join engine 2
    ```
    docker -H tcp://localhost:1002 ${JOIN_COMMAND}
    ```

5. Join engine 3
    ```
    docker -H tcp://localhost:1003 ${JOIN_COMMAND}
    ```

6. Check status
    ```
    docker -H tcp://localhost:1001 node ls
    ```

7. Destroy Swarm cluster
    ```
    docker kill docker1 docker2 docker3
    docker rm docker1 docker2 docker3
    docker volume rm docker1 docker2 docker3
    ```
