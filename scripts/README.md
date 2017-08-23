scripts
=======

## `dind_ddc`
* [Quickstart (tl;dr)](#quickstart-tldr)
* [Prerequisites](#prerequisites)
* [dind_ddc Usage](#dind_ddc-usage)
  * [Basic usage details](#basic-usage-details)
  * [Container commands details](#container-commands-details)
  * [Additional commands details](#additional-commands-details)
  * [Environment Variable Overrides](#environment-variable-overrides)
* [Examples](#examples)
  * [Launching Docker EE with default configuration](#launching-docker-ee-with-default-configuration)
  * [Using an environment file for persistent settings](#using-an-environment-file-for-persistent-settings)
  * [Pre-production DDC](#pre-production-ddc)
    * [Create .tar.gz archives](#create-targz-archives)
  * [Launching UCP and DTR in various configurations](#launching-ucp-and-dtr-in-various-configurations)
  * [Jenkins Demo](#jenkins-demo)
  * [HRM Example Usage](#hrm-example-usage)

## Quickstart (tl;dr)
Check out the [Prerequisites](#prerequisites) and then go down to [Launching Docker EE with default configuration](#launching-docker-ee-with-default-configuration) for released versions or [Environment Variable Overrides](#environment-variable-overrides) for custom settings you can pass as well as [Using an environment file for persistent settings](#using-an-environment-file-for-persistent-settings) to make the management of your custom settings more manageable.  See [Pre-production DDC](#pre-production-ddc) for details of how to launch an environment with pre-production images.

Get a demo environment with 4 commands:
```bash
# you only need to create the tars once
$ ./dind_ddc ucp_create_tar
$ ./dind_ddc dtr_create_tar

# this starts the environment
$ ./dind_ddc create_all

# start jenkins
$ ./dind_ddc launch_jenkins
```

## Prerequisites
  * Docker for Mac installed
    * I would suggest increasing the RAM in the Docker for Mac VM to 4 GB but it will run on 2 GB as long as you do not put heavy workloads on it
  * Have the tarball of the UCP and DTR images in `~/ddc`, keeping the default names from [UCP offline tarballs](https://docs.docker.com/datacenter/ucp/2.1/guides/admin/install/install-offline/) and [DTR offline tarballs](https://docs.docker.com/datacenter/dtr/2.2/guides/admin/install/install-offline/)
    * Alternatively, use the `UCP_IMAGES` and `DTR_IMAGES` env vars to override the full path to the tarballs
    * For pre-release images, see [Pre-production DDC](#pre-production-ddc)
  * Have a DDC license file in `~/Downloads/docker_subscription.lic`
    * Alternatively, use the `DDC_LICENSE` env var to override the full path to the license
  * Must have the following ports available on your host:
    * `100n` - TCP connection to Docker engines where n is 1-n number of engines you're running
    * `8181`, `443`- DTR (HTTP and HTTPS)
    * `4443` - UCP (HTTPS)
    * `80`, `8443` - UCP HRM (HTTP and HTTPS)
      * see [HRM Example Usage](#hrm-example-usage) for HRM usage

## `dind_ddc` Usage
```
$ ./dind_ddc
Basic usage: (see README.md for full command details)
  ./dind_ddc {create_all|create_swarm|install_ucp|install_dtr|launch_jenkins|destroy_swarm|env_info|status}

Container commands:
  ./dind_ddc {start|stop|pause|unpause|recycle}

Additional commands:
  ./dind_ddc {connect_engine|create_net_alias|remove_net_alias|recreate_net_alias|ucp_create_tar|dtr_create_tar}

To view current set environment variables, run ./dind_ddc env_info

$ ./dind_ddc env_info
DIND_ENV:
PROJECT:        dind-ddc
DIND_TAG:       ee-17.06
ENGINE_OPTS:
MANAGERS:       1
WORKERS:        2
UCP_REPO:       docker/ucp
UCP_VERSION:    2.2.0
UCP_IMAGES:     /Users/mbentley/ddc/ucp_images_2.2.0.tar.gz
UCP_OPTIONS:
DTR_REPO:       docker/dtr
DTR_VERSION:    2.3.0
DTR_IMAGES:     /Users/mbentley/ddc/dtr-2.3.0.tar.gz
DDC_LICENSE:    /Users/mbentley/Downloads/docker_subscription.lic
DTR_OPTIONS:
DTR_REPLICAS:   1
DIND_SUBNET:    172.250.1.0/24
DIND_DNS:       192.168.65.1
DIND_RESTART:   unless-stopped
NET_IF:         en0
ALIAS_IP:       10.1.2.3
DOMAIN_NAME:    demo.mac
GH_USERNAME:    mbentley
```

### Basic usage details
  * `create_all` - create a 3 node Swarm mode cluster (1 manager 2 workers), install UCP, and install DTR
  * `create_swarm` - create 3 node Swarm mode cluster; 1 manager and 2 workers
  * `install_ucp` - run through the UCP installation of 1 manager and 2 workers
  * `install_dtr` - install DTR on `docker2`
  * `launch_jenkins` - launch Jenkins using [dockersolutions/jenkins](https://github.com/docker/solutions-jenkins)
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
  * `recreate_net_alias` - removes and then creates network alias
  * `ucp_create_tar` - create a tarball of the UCP images
  * `dtr_create_tar` - create a tarball of the DTR images

### Environment Variable Overrides
If you wish to have your environment variables stored in a single file that can be referenced instead of manually settings them each time, see [Using an environment file for persistent settings](#using-an-environment-file-for-persistent-settings).

  * `DIND_ENV` - environment variable file to source for the below environment variable overrides
  * `PROJECT` - prefix for all resources; allows you to run multiple environments (although it is still one at a time)
  * `DIND_TAG` - docker image tag used to run docker
    * see the [docker-in-docker README](../README.md) for the available tags
  * `MANAGERS` - number of Swarm managers (also used to set number of UCP managers)
  * `WORKERS` - number of Swarm workers (also used to set number of UCP workers)
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
  * `DTR_OPTIONS` - additional DTR install options
  * `DTR_REPLICAS` - number of DTR replicas to install
  * `DDC_LICENSE` - path to your DDC license
  * `DIND_SUBNET` - subnet used for the bridge network created
  * `DIND_DNS` - DNS server to use for the docker daemons running in docker
  * `DIND_RESTART` - restart policy for the docker daemon containers
  * `ALIAS_IP` - IP address to set as an alias to your network interface; used to keep static IP when changing networks
  * `NET_IF` - customize the network interface name used for creating the ALIAS_IP
  * `DOMAIN_NAME` - domain name to use for Jenkins behind HRM
  * `GH_USERNAME` - GitHub username to pass to Jenkins for configuration

*Note*: To see the default values, run `./dind_ddc env_info`

## Examples

### Launching Docker EE with default configuration
```
./dind_ddc create_all
```

[![asciicast](https://asciinema.org/a/125041.png)](https://asciinema.org/a/125041)

### Using an environment file for persistent settings
With the many configuration options comes the difficulty in keeping track of the environment variables you've set.  To make this easier, use an environment variable file. This section covers how to do so with an example of launching Docker EE using tech preview images. There are also may other scenarios that you can launch enviroments for with `dind_ddc`.  See [Launching UCP and DTR in various configurations](#launching-ucp-and-dtr-in-various-configurations) for examples.

1. Create or modify one of the example environment files with the custom variables you would like to use while launching your environment. There are example environment files for [tech preview](./17.06-tp.env), [beta](./17.06-beta.env), [17.03](./17.03.env), and [17.06](./17.06.env) in this repository.

2. There are multiple ways to launch Docker EE while sourcing an env file for your custom settings:

    * Directly source the env file:
    ```
    . ${PWD}/17.03.env
    ./dind_ddc create_all
    ```

    * Export `DIND_ENV` to tell the `dind_ddc` script where to find the env file:
    ```
    export DIND_ENV="${PWD}/17.03.env"
    ./dind_ddc create_all
    ```

    * One-liner to pass the env file location to the `dind_ddc` script:
    ```
    DIND_ENV=${PWD}/17.03.env ./dind_ddc create_all
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

Before you can run UCP and/or DTR dev or tech preview (TP) images, you must [create offline tarballs](#create-targz-archives) of the images.  The below examples utilize exporting environment variables.  See `DIND_ENV` in [Environment Variable Overrides](#environment-variable-overrides) if you'd like to utilize a file with environment variables instead.

* UCP standalone
  ```
  ./dind_ddc create_swarm
  ./dind_ddc install_ucp
  ```

* UCP in HA (3 managers, 3 workers) with DTR on the first worker
  ```
  export MANAGERS=3 \
    WORKERS=3
  ./dind_ddc create_all
  ```

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

### Jenkins Demo

Launching Jenkins allows for utilizing a local demo environment.  To bootstrap and demo Jenkins, do the following:

1. Launch Jenkins:
    ```
    $ ./dind_ddc launch_jenkins
    ```

2. Add a hosts entries in /etc/hosts to point to HRM:
    ```
    $ echo "10.1.2.3 jenkins.demo.mac docker-demo-dev.demo.mac docker-demo-test.demo.mac docker-demo-prd.demo.mac" sudo tee -a /etc/hosts
    ```

3. Login to Jenkins and initialize Jenkins:
    * http://jenkins.demo.mac (u - demo; p - docker123)
    * Execute the job `util > _initialize-demo-env`.  This will do the following:
      * Download a client bundle
      * Login to your DTR
      * Initialize Docker Content Trust delegations for the docker-demo and official image repos in DTR
      * Populate DTR with some official content

4. Execute the job `docker-demo_build` to build and deploy the docker-demo application.

5. Look at the demo application deployed at http://docker-demo-dev.demo.mac/db

### HRM Example Usage

Create a service and test it.  You can also add a hosts file entry so you can bring up the site in a browser.  For HTTPS, you will still need to specify the port for now (8443).

Create a basic service:
```
$ docker -H tcp://localhost:1001 \
    service create \
    --name nginx \
    --network ucp-hrm \
    --label "com.docker.ucp.mesh.http.80=external_route=http://nginx.test,internal_port=80" \
    nginx:alpine
```

Test with `curl`:
```
$ curl -H "Host: nginx.test" http://10.1.2.3
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

Add a hosts file entry for use with a browser to access application at http://nginx.test:
```
$ echo "10.1.2.3 nginx.test" sudo tee -a /etc/hosts
```
