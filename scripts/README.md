scripts
=======

## `dind_ddc`

## tl;dr
Check out the [Prerequisites](#prerequisites) and then go down to [Example - starting DDC](#example---starting-ddc) for released versions or [Pre-production DDC](#pre-production-ddc) for how to launch an environment with pre-production images.

## Prerequisites
  * Docker for Mac installed
    * I would suggest increasing the RAM in the Docker for Mac VM to 4 GB
  * Have the tarball of the UCP and DTR images in `~/ddc`, keeping the default names from [UCP offline tarballs](https://docs.docker.com/datacenter/ucp/2.1/guides/admin/install/install-offline/) and [DTR offline tarballs](https://docs.docker.com/datacenter/dtr/2.2/guides/admin/install/install-offline/)
    * Alternatively, use the `UCP_IMAGES` and `DTR_IMAGES` env vars to override the full path to the tarballs
    * For pre-release images, see [Pre-production DDC](#pre-production-ddc)
  * Have a DDC license file in `~/Downloads/docker_subscription.lic`
    * Alternatively, use the `DDC_LICENSE` env var to override the full path to the license
  * Must have the following ports available on your host:
    * `1001`, `1002`, `1003` - TCP connection to Docker engines
    * `80`, `443`- DTR (HTTP and HTTPS)
    * `4443` - UCP (HTTPS)
    * `8181`, `8443` - UCP HRM (HTTP and HTTPS)
      * see [HRM Example Usage](#hrm-example-usage) for HRM usage

## `dind_ddc` Usage
```
$ ./dind_ddc
Basic usage: (see README.md for full command details)
  ./dind_ddc {create_all|create_swarm|install_ucp|install_dtr|destroy_swarm|env_info|status}

Container commands:
  ./dind_ddc {start|stop|pause|unpause|recycle}

Additional commands:
  ./dind_ddc {connect_engine|create_net_alias|remove_net_alias|ucp_create_tar|dtr_create_tar}

Current set environment variables:
DIND_TAG:       ee-17.03
ENGINE_OPTS:
SWARM_HA:       false
UCP_REPO:       docker/ucp
UCP_VERSION:    2.1.4
UCP_IMAGES:     /Users/mbentley/ddc/ucp_images_2.1.4.tar.gz
UCP_OPTIONS:
DTR_REPO:       docker/dtr
DTR_VERSION:    2.2.5
DTR_IMAGES:     /Users/mbentley/ddc/dtr-2.2.5.tar.gz
DDC_LICENSE:    /Users/mbentley/Downloads/docker_subscription.lic
DIND_SUBNET:    172.250.0.0/16
DIND_DNS:       8.8.8.8
DIND_RESTART:   unless-stopped
NET_IF:         en0
ALIAS_IP:       10.1.2.3
```

### Basic usage details
  * `create_all` - create a 3 node Swarm mode cluster (1 manager 2 workers), install UCP, and install DTR
  * `create_swarm` - create 3 node Swarm mode cluster; 1 manager and 2 workers
  * `install_ucp` - run through the UCP installation of 1 manager and 2 workers
  * `install_dtr` - install DTR on `docker2`
  * `destroy_swarm` - remove Swarm, the engines, and all persistent data
  * `env_info` - display enviroment variable overrides currently set

### Container commands details
  * `start` - start ddc-lb, docker1, docker2, and docker3 daemon containers
  * `stop` - stop ddc-lb, docker1, docker2, and docker3 daemon containers
  * `pause` - pause ddc-lb, docker1, docker2, and docker3 daemon containers
  * `unpause` - unpause ddc-lb, docker1, docker2, and docker3 daemon containers
  * `recycle` - stop, remove, and re-create the docker engines and `dind` network, keeping persistent data (useful for upgrades)

### Additional commands details
  * `connect_engine` - helper script used to set `DOCKER_HOST` to communicate to a specific engine
  * `create_net_alias` - create a network alias used for keeping a persistent IP no matter when you are (only used for D4M)
  * `remove_net_alias` - remove network alias
  * `ucp_create_tar` - create a tarball of the UCP images
  * `dtr_create_tar` - create a tarball of the DTR images

### Environment Variable Overrides
  * `DIND_TAG` - docker image tag used to run docker
    * see https://hub.docker.com/r/mbentley/docker-in-docker/tags/ for the tags
  * `SWARM_HA` - allows you to setup 1 or 3 managers of Swarm; will also install UCP HA if `true`
  * `ENGINE_OPTS` - custom engine options to append to the defaults
  * `UCP_REPO` - image to use for UCP (without the tag)
  * `UCP_VERSION` - change the UCP version installed
    * see https://hub.docker.com/r/docker/ucp/tags/ for the tags
  * `UCP_IMAGES` - path to the `.tar.gz` of the UCP images
    * see https://docs.docker.com/datacenter/ucp/2.1/guides/admin/install/install-offline/#versions-available for the tar.gz
  * `UCP_OPTIONS` - additional UCP install options
  * `DTR_REPO` - image to use for DTR (without the tag)
  * `DTR_VERSION` - change the DTR version installed
    * see https://hub.docker.com/r/docker/dtr/tags/ for the tags
  * `DTR_IMAGES` - path to the `.tar.gz` of the DTR images
    * see https://docs.docker.com/datacenter/dtr/2.2/guides/admin/install/install-offline/#versions-available for the tar.gz
  * `DDC_LICENSE` - path to your DDC license
  * `DIND_SUBNET` - subnet used for the bridge network created
  * `DIND_DNS` - DNS server to use for the docker daemons running in docker
  * `DIND_RESTART` - restart policy for the docker daemon containers
  * `ALIAS_IP` - IP address to set as an alias to your network interface; used to keep static IP when changing networks
  * `NET_IF` - customize the network interface name used for creating the ALIAS_IP

*Note*: To see the default values, run `./dind_ddc env_info`

### Example - starting DDC
```
./dind_ddc create_all
```

[![asciicast](https://asciinema.org/a/125041.png)](https://asciinema.org/a/125041)

### HRM Example Usage

Enable HRM in the UCP UI, specify ports 8181 and 8443 for HTTP and HTTPS, respectively.  Create a service and test it.  You can also add a hosts file entry so you can bring up the site in a browser but you will still need to specify the port for now.

```
# create the service
$ docker -H tcp://localhost:1001 \
  service create \
  --name nginx \
  --network ucp-hrm \
  --label "com.docker.ucp.mesh.http.80=external_route=http://nginx.test,internal_port=80" \
  nginx:latest

# test with curl
$ curl -H "Host: nginx.test" http://10.1.2.3:8181
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

### Pre-production DDC

#### Create .tar.gz archives

* UCP

  Automatic:
  ```
  export UCP_REPO="dockerorcadev/ucp" UCP_VERSION="2.2.0-tp6" UCP_OPTIONS="--image-version dev:"
  ./dind_ddc ucp_create_tar
  ```

  Manual:
  ```
  TAG="2.2.0-tp6"
  docker run --rm dockerorcadev/ucp:"${TAG}" images --list --image-version dev: | xargs -L 1 docker pull
  docker save -o ucp_images_"${TAG}".tar.gz $(docker run --rm dockerorcadev/ucp:"${TAG}" images --list --image-version dev:) dockerorcadev/ucp:"${TAG}"
  docker rmi $(docker run --rm dockerorcadev/ucp:"${TAG}" images --list --image-version dev:) dockerorcadev/ucp:"${TAG}"
  ```

* DTR

  Automatic:
  ```
  export DTR_REPO="dockerhubenterprise/dtr" DTR_VERSION="2.3.0-tp6"
  ./dind_ddc dtr_create_tar
  ```

  Manual:
  ```
  TAG="2.3.0-tp6"
  docker run --rm dockerhubenterprise/dtr:"${TAG}" images | xargs -L 1 docker pull
  docker save -o dtr-"${TAG}".tar.gz $(docker run --rm dockerhubenterprise/dtr:"${TAG}" images)
  docker rmi $(docker run --rm dockerhubenterprise/dtr:"${TAG}" images)
  ```

### Launching UCP and DTR in various configurations

Before you can run UCP and/or DTR dev or tech preview (TP) images, you must [create offline tarballs](#create-targz-archives) of the images.

* UCP and DTR - UCP (dev/TP) and DTR (dev/TP)
  ```
  export UCP_REPO="dockerorcadev/ucp" \
    UCP_VERSION="2.2.0-tp6" \
    UCP_OPTIONS="--image-version dev:" \
    DTR_REPO="dockerhubenterprise/dtr" \
    DTR_VERSION="2.3.0-tp5" \
    DIND_TAG="ce-test"

  ./dind_ddc create_all
  ```

* UCP and DTR - UCP (dev/TP) images and DTR (stable)
  ```
  export UCP_REPO="dockerorcadev/ucp" \
    UCP_VERSION="2.2.0-tp6" \
    UCP_OPTIONS="--image-version dev:" \
    DIND_TAG="ce-test"

  ./dind_ddc create_all
  ```

* UCP and DTR - UCP (stable) and DTR (dev/TP)
  ```
  export DTR_REPO="dockerhubenterprise/dtr" \
    DTR_VERSION="2.3.0-tp5" \
    DIND_TAG="ce-test"

  ./dind_ddc create_all
  ```

* UCP (dev/TP) only; no DTR
  ```
  export UCP_REPO="dockerorcadev/ucp" \
    UCP_VERSION="2.2.0-tp6" \
    UCP_OPTIONS="--image-version dev:" \
    DIND_TAG="ce-test"

  ./dind_ddc create_swarm

  ./dind_ddc install_ucp
  ```
