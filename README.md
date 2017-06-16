docker-in-docker
================

## Build image
Docker CE
```
docker build \
  -t mbentley/docker-in-docker:ce-17.03 \
  -t mbentley/docker-in-docker:ce \
  -f Dockerfile.ce .
```

Docker EE
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


## Single engine

### Start engine
```
docker run -d \
  --name docker \
  --privileged \
  -p 127.0.0.1:1000:2375 \
  -v /lib/modules:/lib/modules:ro \
  -v docker:/var/lib/docker \
  mbentley/docker-in-docker \
  dockerd -s overlay2 -H unix:///var/run/docker.sock
```

### Communicate to that engine
```
docker -H tcp://localhost:1000 info
```

## Check version
```
docker version
```

### Destroy the Engine
```
docker kill docker
docker rm docker
docker volume rm docker
```

## Swarm
### Create 3 engines
```
for ENGINE_NUM in {1..3}
do
  docker run -d \
    --name docker${ENGINE_NUM} \
    --privileged \
    -p 127.0.0.1:100${ENGINE_NUM}:2375 \
    -v /lib/modules:/lib/modules:ro \
    -v docker${ENGINE_NUM}:/var/lib/docker \
    mbentley/docker-in-docker \
    dockerd -s overlay2 -H unix:///var/run/docker.sock
done
```

### Create a new Swarm
```
docker -H tcp://localhost:1001 swarm init
```

### Get the worker join token and command
```
TOKEN=$(docker -H tcp://localhost:1001 swarm join-token worker -q)
JOIN_COMMAND="swarm join --token ${TOKEN} $(docker container inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' docker1):2377"
```

### Join engine 2
```
docker -H tcp://localhost:1002 ${JOIN_COMMAND}
```

### Join engine 3
```
docker -H tcp://localhost:1003 ${JOIN_COMMAND}
```

### Check status
```
docker -H tcp://localhost:1001 node ls
```

### Destroy Swarm cluster
```
docker kill docker1 docker2 docker3
docker rm docker1 docker2 docker3
docker volume rm docker1 docker2 docker3
```
