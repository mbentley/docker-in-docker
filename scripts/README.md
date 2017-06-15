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
  * `start_engines` - start docker1, docker2, and docker3 daemon containers
  * `stop_engines` - stop docker1, docker2, and docker3 daemon containers
  * `recycle_engines` - stop, remove, and re-create the docker engines, keeping persistent data (useful for upgrades)
  * `destroy_swarm` - remove Swarm, the engines, and all persistent data
  * `output_info` - display enviroment variable overrides currently set

### Environment Variable Overrides
  * `DIND_TAG` - docker image tag used to run docker
    * see https://hub.docker.com/r/mbentley/docker-in-docker/tags/ for the tags
  * `UCP_REPO` - image to use for UCP (without the tag)
  * `UCP_VERSION` - change the UCP version installed
    * see https://hub.docker.com/r/docker/ucp/tags/ for the tags
  * `UCP_IMAGES` - path to location of the `.tar.gz` of the UCP images
    * see https://docs.docker.com/datacenter/ucp/2.1/guides/admin/install/install-offline/#versions-available for the tar.gz
  * `UCP_OPTIONS` - additional UCP install options
  * `DTR_REPO` - image to use for DTR (without the tag)
  * `DTR_VERSION` - change the DTR version installed
    * see https://hub.docker.com/r/docker/dtr/tags/ for the tags
  * `DTR_IMAGES` - path to the `.tar.gz` of the DTR images
    * see https://docs.docker.com/datacenter/dtr/2.2/guides/admin/install/install-offline/#versions-available for the tar.gz
  * `DIND_DIR` - directory used to store `/var/run` from the daemons to allow Docker socket access to the engines running in Docker
  * `HOST_IP` - set the host IP that is used for installing UCP and DTR (used for all communication to UCP/DTR)
  * `DIND_SUBNET` - subnet used for the bridge network created
  * `DIND_DNS` - DNS server to use for the docker daemons running in docker

*Note*: To see the default values, run `./dind_ddc output_info`
