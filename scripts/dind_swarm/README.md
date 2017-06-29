`dind_swarm`
============

## tl;dr
Check out the [Prerequisites](#prerequisites) and then go down to [Example - creating Swarm](#example---creating-swarm).

## Prerequisites
  * Docker for Mac installed
    * I would suggest increasing the RAM in the Docker for Mac VM to 4 GB
  * Must have the following ports available on your host:
    * `100n` - where `n` is the number of engines in your Swarm for TCP connection to Docker engines

## `dind_swarm` Usage
```
$ ./dind_swarm
Basic usage: (see README.md for full command details)
  ./dind_swarm {create_swarm|destroy_swarm|output_info}

Container commands:
  ./dind_swarm {start|stop|pause|unpause|recycle}

Additional commands:
  ./dind_swarm {connect_engine}

Current set environment variables:
DIND_TAG:       ee-17.03
ENGINE_OPTS:
MANAGERS:       3
WORKERS:        1
DIND_SUBNET:    172.250.0.0/16
DIND_DNS:       8.8.8.8
DIND_RESTART:   unless-stopped
```

### Basic usage details
  * `create_swarm` - create 3 node Swarm mode cluster; 1 manager and 2 workers
  * `destroy_swarm` - remove Swarm, the engines, and all persistent data
  * `output_info` - display enviroment variable overrides currently set

### Container commands details
  * `start` - start docker daemon containers
  * `stop` - stop docker daemon containers
  * `pause` - pause docker daemon containers
  * `unpause` - unpause docker daemon containers
  * `recycle` - stop, remove, and re-create the docker engines and `dind` network, keeping persistent data (useful for upgrades)

### Additional commands details
  * `connect_engine` - helper script used to set `DOCKER_HOST` to communicate to a specific engine

### Environment Variable Overrides
  * `DIND_TAG` - docker image tag used to run docker
    * see https://hub.docker.com/r/mbentley/docker-in-docker/tags/ for the tags
  * `ENGINE_OPTS` - custom engine options to append to the defaults
  * `MANAGERS` - number of Swarm managers
  * `WORKERS` - number of Swarm workers
  * `DIND_SUBNET` - subnet used for the bridge network created
  * `DIND_DNS` - DNS server to use for the docker daemons running in docker
  * `DIND_RESTART` - restart policy for the docker daemon containers

*Note*: To see the default values, run `./dind_swarm output_info`

### Example - creating Swarm
```
./dind_swarm create_swarm
```
