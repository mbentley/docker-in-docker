scripts
=======

## `dind_ddc`

```
Usage: ./dind_ddc {create_all|create_swarm|connect_engine|install_ucp|install_dtr|recycle_engines|destroy_swarm}
```

### Commands
  * `create_all` - create a 3 node Swarm mode cluster (1 manager 2 workers), install UCP, and install DTR
  * `create_swarm` - create 3 node Swarm mode cluster; 1 manager and 2 workers
  * `connect_engine` - helper script used to set `DOCKER_HOST` to communicate to a specific engine
  * `install_ucp` - run through the UCP installation of 1 manager and 2 workers
  * `install_dtr` - install DTR on `docker2`
  * `recycle_engines` - stop, remove, and re-create the docker engines, keeping persistent data (useful for upgrades)
  * `destroy_swarm` - remove Swarm, the engines, and all persistent data

### Environment Variable Overrides
  * `UCP_VERSION` - change the UCP version installed
  * `DTR_VERSION` - change the DTR version installed
  * `HOST_IP` - set the host IP that is used for installing UCP and DTR (used for all communication to UCP/DTR)
  * `DIND_SUBNET` - subnet used for the bridge network created
  * `DIND_DIR` - directory used to store `/var/run` from the daemons to allow Docker daemon access to the engines running in Docker
  * `DIND_TAG` - docker image tag used to run docker
