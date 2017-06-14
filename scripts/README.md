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

