docker-in-docker
================

## Single engine

### Start engine
```
docker run -it --rm \
  --name docker \
  --privileged \
  -v docker:/var/lib/docker \
  -v /data/docker:/var/run \
  mbentley/docker-in-docker
```

### Communicate to that engine
```
docker -H unix:///data/docker/docker.sock info
```

## Check version
```
docker version
```

## Swarm
### Create 3 engines
```
for ENGINE_NUM in {1..3}
do
  docker run -d \
    --name docker${ENGINE_NUM} \
    --privileged \
    -v docker${ENGINE_NUM}:/var/lib/docker \
    -v /data/docker${ENGINE_NUM}:/var/run \
    mbentley/docker-in-docker
done
```

### Create a new Swarm
```
docker -H unix:///data/docker1/docker.sock swarm init
```

### Get the worker join token and command
```
TOKEN=$(docker -H unix:///data/docker1/docker.sock swarm join-token worker -q)
JOIN_COMMAND="swarm join --token ${TOKEN} $(docker container inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' docker1):2377"
```

### Join engine 2
```
docker -H unix:///data/docker2/docker.sock ${JOIN_COMMAND}
```

### Join engine 3
```
docker -H unix:///data/docker3/docker.sock ${JOIN_COMMAND}
```

### Check status
```
docker -H unix:///data/docker1/docker.sock node ls
```

### Destroy Swarm cluster
```
docker kill docker1 docker2 docker3
docker rm docker1 docker2 docker3
docker volume rm docker1 docker2 docker3
sudo rm -rf /data/docker*/*
```
