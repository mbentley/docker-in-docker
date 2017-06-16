scripts
=======

## `dind_ddc`

## Prerequisites
  * Docker for Mac installed
  * Have the `.tar.gz` of the UCP and DTR images in `~/ddc`, keeping the default names
    * Alternatively, use the `UCP_IMAGES` and `DTR_IMAGES` env vars to override
    * For pre-release images, see [Pre-production DDC](#pre-production-ddc)
  * Have a DDC license file in `~/Downloads/docker_subscription.lic`
    * Alternatively, use the `DDC_LICENSE` env var to override

```
$ ./dind_ddc
Basic Usage:
  ./dind_ddc {create_all|create_swarm|install_ucp|install_dtr|destroy_swarm|output_info}

Additional utility usage:
  ./dind_ddc {connect_engine|start_engines|stop_engines|recycle_engines|create_net_alias|remove_net_alias}

Current set environment variables:
DIND_TAG        ee-17.03
UCP_REPO:       docker/ucp
UCP_VERSION:    2.1.4
UCP_IMAGES:     /Users/mbentley/ddc/ucp_images_2.1.4.tar.gz
UCP_OPTIONS:
DTR_REPO:       docker/dtr
DTR_VERSION:    2.2.5
DTR_IMAGES:     /Users/mbentley/ddc/dtr-2.2.5.tar.gz
DDC_LICENSE:    /Users/mbentley/Downloads/docker_subscription.lic
DIND_SUBNET:    172.19.0.0/16
DIND_DNS:       8.8.8.8
NET_IF:         en0
ALIAS_IP:       10.1.2.3
```

### Basic Usage
  * `create_all` - create a 3 node Swarm mode cluster (1 manager 2 workers), install UCP, and install DTR
  * `create_swarm` - create 3 node Swarm mode cluster; 1 manager and 2 workers
  * `install_ucp` - run through the UCP installation of 1 manager and 2 workers
  * `install_dtr` - install DTR on `docker2`
  * `destroy_swarm` - remove Swarm, the engines, and all persistent data
  * `output_info` - display enviroment variable overrides currently set

### Additional utility usage
  * `connect_engine` - helper script used to set `DOCKER_HOST` to communicate to a specific engine
  * `start_engines` - start docker1, docker2, and docker3 daemon containers
  * `stop_engines` - stop docker1, docker2, and docker3 daemon containers
  * `recycle_engines` - stop, remove, and re-create the docker engines, keeping persistent data (useful for upgrades)
  * `create_net_alias` - create a network alias used for keeping a persistent IP no matter when you are (only used for D4M)
  * `remove_net_alias` - remove network alias

### Environment Variable Overrides
  * `DIND_TAG` - docker image tag used to run docker
    * see https://hub.docker.com/r/mbentley/docker-in-docker/tags/ for the tags
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
  * `ALIAS_IP` - IP address to set as an alias to your network interface; used to keep static IP when changing networks
  * `NET_IF` - customize the network interface name used for creating the ALIAS_IP

*Note*: To see the default values, run `./dind_ddc output_info`

### Example - starting DDC
```
./dind_ddc create_all
```
<details>
  <summary>Expanded details</summary>

```
$ ./dind_ddc create_all
Creating IP alias (requires sudo)...
done.

Checking for subnet availability...
Subnet (172.19.0.0/16) is available.
done.

Creating 'dind' network with the subnet 172.19.0.0/16...
ed41d564329080852ae97f0bc6029b366a59db192490a7811c32ecb404cd2b2c
done.

Launching docker engines (docker1, docker2, docker3)...
10f7aea3d1c3704a45ae5a4c316d6f260adfe2a19618043833ee49b2d6f85f53
62b9763b072c9b466fecbafe9309da535a7a2ad3e91edb16c545d3c50ab02810
50d58edcf904c004d5b5e0cfb5b99b2204839199590e1f7896a99c63838fcd78
done.

Initializing Swarm on docker1...
Swarm initialized: current node (e3w6edykiiqkvtt827a4o9vyn) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-1n1f9qnjxsa8yews8pjd2g3jfbf8vl8zgduhz76trryfqqy303-det6vrktbnsi2hvq6itwnugmj \
    172.19.0.2:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

done.

Joining docker2 to the Swarm...
This node joined a swarm as a worker.
done.

Joining docker3 to the Swarm...
This node joined a swarm as a worker.
done.

IP alias (10.1.2.3) already exists
done.

Loading UCP images on docker1...
9f8566ee5135: Loading layer [==================================================>]  5.054MB/5.054MB
3b8318738c25: Loading layer [==================================================>]  944.1kB/944.1kB
dc1f4b2538bf: Loading layer [==================================================>]  13.74MB/13.74MB
Loaded image: docker/ucp:latest
Loaded image: docker/ucp:2.1.4
23b9c7b43573: Loading layer [==================================================>]   4.23MB/4.23MB
a949efa8c775: Loading layer [==================================================>]  9.686MB/9.686MB
850116bae95c: Loading layer [==================================================>]  2.048kB/2.048kB
5d614d1149eb: Loading layer [==================================================>]  1.136MB/1.136MB
3af87a5151a5: Loading layer [==================================================>]  6.144kB/6.144kB
bbc4f54d4086: Loading layer [==================================================>]  6.144kB/6.144kB
031874a730b2: Loading layer [==================================================>]  2.048kB/2.048kB
Loaded image: docker/ucp-hrm:2.1.4
8feb47f360e9: Loading layer [==================================================>]   6.51MB/6.51MB
b37a2b054023: Loading layer [==================================================>]  47.78MB/47.78MB
Loaded image: docker/ucp-auth-store:2.1.4
6dca51f119c0: Loading layer [==================================================>]  1.693MB/1.693MB
2cef8032f128: Loading layer [==================================================>]  4.309MB/4.309MB
6bb55568e86e: Loading layer [==================================================>]  17.56MB/17.56MB
Loaded image: docker/ucp-controller:2.1.4
9d3227c1793b: Loading layer [==================================================>]  121.3MB/121.3MB
a1a54d352248: Loading layer [==================================================>]  15.87kB/15.87kB
511ddc11cf68: Loading layer [==================================================>]  11.78kB/11.78kB
08f405d988e4: Loading layer [==================================================>]  5.632kB/5.632kB
73e5d2de6e3e: Loading layer [==================================================>]  3.072kB/3.072kB
3b94418450fe: Loading layer [==================================================>]  39.01MB/39.01MB
8e2f2b149747: Loading layer [==================================================>]  9.216kB/9.216kB
dceed9c527f9: Loading layer [==================================================>]  3.072kB/3.072kB
da6b50c6c8f8: Loading layer [==================================================>]  4.528MB/4.528MB
5d5a2ad2d04e: Loading layer [==================================================>]  10.75kB/10.75kB
Loaded image: docker/ucp-dsinfo:2.1.4
b21826ae23de: Loading layer [==================================================>]  6.209MB/6.209MB
d5027789d9ae: Loading layer [==================================================>]  13.64MB/13.64MB
Loaded image: docker/ucp-agent:2.1.4
5131a88bd5c6: Loading layer [==================================================>]  944.1kB/944.1kB
4a8c1b5b6154: Loading layer [==================================================>]  15.59MB/15.59MB
ca0b9e4aaf87: Loading layer [==================================================>]   2.56kB/2.56kB
Loaded image: docker/ucp-swarm:2.1.4
023e9bff08d6: Loading layer [==================================================>]  79.49MB/79.49MB
5d802a36f047: Loading layer [==================================================>]  3.072kB/3.072kB
5cc4537692ba: Loading layer [==================================================>]  3.072kB/3.072kB
f9cdb5738c69: Loading layer [==================================================>]  4.122MB/4.122MB
82b699525dde: Loading layer [==================================================>]  4.204MB/4.204MB
Loaded image: docker/ucp-metrics:2.1.4
60cf0f3897af: Loading layer [==================================================>]  1.693MB/1.693MB
97fe8575261d: Loading layer [==================================================>]  15.64MB/15.64MB
3284e8d66136: Loading layer [==================================================>]   3.32MB/3.32MB
Loaded image: docker/ucp-auth:2.1.4
685912c19142: Loading layer [==================================================>]  6.273MB/6.273MB
354ac61b9829: Loading layer [==================================================>]  8.273MB/8.273MB
fa7f45575e7c: Loading layer [==================================================>]  4.608kB/4.608kB
46e829c74031: Loading layer [==================================================>]  14.02MB/14.02MB
Loaded image: docker/ucp-compose:2.1.4
bfd9c21c0958: Loading layer [==================================================>]  6.209MB/6.209MB
45a93cc0bd17: Loading layer [==================================================>]  2.048kB/2.048kB
fac611fd6365: Loading layer [==================================================>]  6.316MB/6.316MB
Loaded image: docker/ucp-cfssl:2.1.4
800d63138a52: Loading layer [==================================================>]  34.01MB/34.01MB
Loaded image: docker/ucp-etcd:2.1.4
done.

Loading docker/ucp-agent:2.1.4 on docker 2...
9f8566ee5135: Loading layer [==================================================>]  5.054MB/5.054MB
b21826ae23de: Loading layer [==================================================>]  6.209MB/6.209MB
d5027789d9ae: Loading layer [==================================================>]  13.64MB/13.64MB
Loaded image: docker/ucp-agent:2.1.4
done.

Loading docker/ucp-agent:2.1.4 on docker 3...
9f8566ee5135: Loading layer [==================================================>]  5.054MB/5.054MB
b21826ae23de: Loading layer [==================================================>]  6.209MB/6.209MB
d5027789d9ae: Loading layer [==================================================>]  13.64MB/13.64MB
Loaded image: docker/ucp-agent:2.1.4
done.

Installing UCP on docker1 using controller port 4443...
hostname: illegal option -- -
usage: hostname [-fs] [name-of-host]
INFO[0000] Verifying your system is compatible with UCP 2.1.4 (10e6c44)
INFO[0000] Your engine version 17.03.2-ee-4, build 1e6d71e (4.9.27-moby) is compatible
INFO[0000] All required images are present
WARN[0000] None of the hostnames we'll be using in the UCP certificates [docker1 127.0.0.1 172.17.0.1 172.19.0.2 10.1.2.3 wafflemaker  172.19.0.2] contain a domain component.  Your generated certs may fail TLS validation unless you only use one of these shortnames or IPs to connect.  You can use the --san flag to add more aliases
INFO[0004] Establishing mutual Cluster Root CA with Swarm
INFO[0007] Installing UCP with host address 172.19.0.2 - If this is incorrect, please specify an alternative address with the '--host-address' flag
INFO[0007] Generating UCP Client Root CA
INFO[0007] Deploying UCP Service
INFO[0007] Injecting user supplied license file
INFO[0054] Installation completed on docker1 (node e3w6edykiiqkvtt827a4o9vyn)
INFO[0057] Installation completed on docker2 (node z6dy36tzdx0hl4rnkbvtbqn29)
INFO[0057] Installation completed on docker3 (node o09bw6470dqiz0995kuchyhtk)
INFO[0057] UCP Instance ID: RSJR:KAOC:EA3Q:6JOP:L5VD:7X2E:DQUA:UBJ3:OVMM:HUEO:RQS4:SOWJ
INFO[0057] UCP Server SSL: SHA-256 Fingerprint=78:67:39:77:5A:AE:30:D1:EA:BA:79:93:2D:0C:1C:B4:0E:3C:36:25:82:0D:5A:D6:8E:62:26:E1:B6:31:66:57
INFO[0057] Login to UCP at https://172.19.0.2:4443
INFO[0057] Username: admin
INFO[0057] Password: (your admin password)

UCP should now be available at https://10.1.2.3:4443/
  Username: admin       Password: docker123
done.

Loading DTR images on docker2...
23b9c7b43573: Loading layer [==================================================>]   4.23MB/4.23MB
b87c19696070: Loading layer [==================================================>]  8.278MB/8.278MB
27c2f8bd1857: Loading layer [==================================================>]   47.1MB/47.1MB
ebd312aad335: Loading layer [==================================================>]  1.536kB/1.536kB
f471078b86d1: Loading layer [==================================================>]  40.97MB/40.97MB
Loaded image: docker/dtr-rethink:2.2.5
ff143e5bce0a: Loading layer [==================================================>]   4.23MB/4.23MB
3cb6830ca2e7: Loading layer [==================================================>]  2.048kB/2.048kB
e73bf1047fe7: Loading layer [==================================================>]  1.536kB/1.536kB
dc232dfb7f68: Loading layer [==================================================>]  2.048kB/2.048kB
5e0b767a03ab: Loading layer [==================================================>]  1.536kB/1.536kB
ec36f624fe76: Loading layer [==================================================>]  2.048kB/2.048kB
71241751a479: Loading layer [==================================================>]  3.072kB/3.072kB
045f164e0a6b: Loading layer [==================================================>]  81.77MB/81.77MB
89d40fe8cf03: Loading layer [==================================================>]   2.56kB/2.56kB
af331c24c0b1: Loading layer [==================================================>]  33.68MB/33.68MB
Loaded image: docker/dtr-garant:2.2.5
748e47337872: Loading layer [==================================================>]  42.23MB/42.23MB
Loaded image: docker/dtr-notary-server:2.2.5
cbf8907b477a: Loading layer [==================================================>]  24.69MB/24.69MB
55f79e186d65: Loading layer [==================================================>]  30.38MB/30.38MB
Loaded image: docker/dtr-postgres:2.2.5
1d036f6d54e9: Loading layer [==================================================>]  958.5kB/958.5kB
7d8c9430d1bd: Loading layer [==================================================>]   2.56kB/2.56kB
944588902a00: Loading layer [==================================================>]  26.62MB/26.62MB
Loaded image: docker/dtr-content-cache:2.2.5
6981e3ea5e0b: Loading layer [==================================================>]  37.29MB/37.29MB
Loaded image: docker/dtr-nginx:2.2.5
373f378ebe3f: Loading layer [==================================================>]  39.46MB/39.46MB
Loaded image: docker/dtr-registry:2.2.5
950d2baaa5d1: Loading layer [==================================================>]  43.87MB/43.87MB
Loaded image: docker/dtr:2.2.5
de587db3d188: Loading layer [==================================================>]  41.09MB/41.09MB
Loaded image: docker/dtr-notary-signer:2.2.5
abb183aedf60: Loading layer [==================================================>]  286.8MB/286.8MB
64060be7eec4: Loading layer [==================================================>]  218.8MB/218.8MB
Loaded image: docker/dtr-jobrunner:2.2.5
aa64e7300711: Loading layer [==================================================>]  94.08MB/94.08MB
Loaded image: docker/dtr-api:2.2.5
done.

Installing DTR on docker2 using DTR replica ports 80 and 443...
INFO[0000] Beginning Docker Trusted Registry installation
INFO[0000] Validating UCP cert
INFO[0000] Connecting to UCP
INFO[0000] UCP cert validation successful
INFO[0000] The UCP cluster contains the following nodes: docker1, docker3, docker2
INFO[0001] verifying [80 443] ports on docker2
INFO[0000] Validating UCP cert
INFO[0000] Connecting to UCP
INFO[0000] UCP cert validation successful
INFO[0000] Checking if the node is okay to install on
INFO[0000] Creating network: dtr-ol
INFO[0000] Connecting to network: dtr-ol
INFO[0000] Waiting for phase2 container to be known to the Docker daemon
INFO[0001] Starting UCP connectivity test
INFO[0001] UCP connectivity test passed
INFO[0001] Setting up replica volumes...
INFO[0001] Creating initial CA certificates
INFO[0001] Bootstrapping rethink...
INFO[0001] Creating dtr-rethinkdb-20be500c5750...
INFO[0005] Waiting for database dtr2 to exist
INFO[0010] Generated TLS certificate.                    domain=10.1.2.3
INFO[0010] License config copied from UCP.
INFO[0010] Migrating db...
INFO[0000] Migrating database schema                     fromVersion=0 toVersion=6
INFO[0005] Waiting for database notaryserver to exist
INFO[0005] Waiting for database notarysigner to exist
INFO[0006] Waiting for database jobrunner to exist
INFO[0008] Migrated database from version 0 to 6
INFO[0018] Starting all containers...
INFO[0018] Getting container configuration and starting containers...
INFO[0019] Recreating dtr-rethinkdb-20be500c5750...
INFO[0025] Creating dtr-registry-20be500c5750...
INFO[0028] Creating dtr-garant-20be500c5750...
INFO[0031] Creating dtr-api-20be500c5750...
INFO[0034] Creating dtr-notary-server-20be500c5750...
INFO[0037] Recreating dtr-nginx-20be500c5750...
INFO[0039] Creating dtr-jobrunner-20be500c5750...
INFO[0042] Creating dtr-notary-signer-20be500c5750...
INFO[0045] Creating dtr-scanningstore-20be500c5750...
INFO[0047] Trying to get the kv store connection back after reconfigure
INFO[0048] Verifying auth settings...
INFO[0048] Waiting for DTR to start...
INFO[0053] Waiting for DTR to start...
INFO[0058] Waiting for DTR to start...
INFO[0058] Authentication test passed.
INFO[0059] Successfully registered dtr with UCP
INFO[0059] Background tag migration started
INFO[0059] Installation is complete
INFO[0059] Replica ID is set to: 20be500c5750
INFO[0059] You can use flag '--existing-replica-id 20be500c5750' when joining other replicas to your Docker Trusted Registry Cluster

DTR should now be available at https://10.1.2.3/
  Username: admin       Password: docker123
done.
```
</details>

### Pre-production DDC

#### UCP

Create .tar.gz of the images you want to run
```
TAG="2.2.0-tp5"
docker run --rm dockerorcadev/ucp:"${TAG}" images --list --image-version dev: | xargs -L 1 docker pull
docker save -o ucp_images_"${TAG}".tar.gz $(docker run --rm dockerorcadev/ucp:"${TAG}" images --list --image-version dev:) dockerorcadev/ucp:"${TAG}"
docker rmi $(docker run --rm dockerorcadev/ucp:"${TAG}" images --list --image-version dev:) dockerorcadev/ucp:"${TAG}"
```

Launch UCP with dev images
```
export UCP_REPO="dockerorcadev/ucp" UCP_VERSION="2.2.0-tp5" UCP_OPTIONS="--image-version dev:" DIND_TAG="ce-test"
./dind_ddc create_swarm
./dind_ddc install_ucp
```

#### DTR
to add later
