#!/bin/bash

set -e

# set the container variable so that processes know we are in a docker container
export container=docker

DOCKERD_PID="$(pgrep dockerd || true)"
if [ -f "/var/run/docker.pid" ] && [ -z "${DOCKERD_PID}" ]
then
  # pid file exists and docker isn't running
  echo -n "INFO: Removing stale pid file (/var/run/docker.pid)..."
  rm /var/run/docker.pid
  echo "done"
elif [ -n "${DOCKERD_RUNNING}" ]
then
  # docker is running
  echo "ERROR: Docker is already running!"
  echo "  Hint: This script should only be executed as the container entrypoint!"
  exit 1
fi

# set mount propagation
if [ -n "${MOUNT_PROPAGATION}" ]
then
  for MOUNT in ${MOUNT_PROPAGATION}
  do
    echo -n "INFO: Mounting ${MOUNT} as 'rshared'..."
    mount --make-rshared "${MOUNT}"
    echo "done"
  done
fi

# Mount /tmp, if needed
if ! mountpoint -q /tmp
then
  echo -n "INFO: Mounting /tmp with as tmpfs..."
  mount -t tmpfs none /tmp
  echo "done"
fi

# cgroup v2: enable nesting (from https://github.com/moby/moby/blob/v20.10.8/hack/dind#L28-L38)
if [ -f /sys/fs/cgroup/cgroup.controllers ]
then
  echo -n "INFO: cgroups v2 detected; enabling nesting..."
  # move the processes from the root group to the /init group,
  # otherwise writing subtree_control fails with EBUSY.
  # An error during moving non-existent process (i.e., "cat") is ignored.
  mkdir -p /sys/fs/cgroup/init
  xargs -rn1 < /sys/fs/cgroup/cgroup.procs > /sys/fs/cgroup/init/cgroup.procs || :
  # enable controllers
  sed -e 's/ / +/g' -e 's/^/+/' < /sys/fs/cgroup/cgroup.controllers \
    > /sys/fs/cgroup/cgroup.subtree_control
  echo "done"
fi

# check to see if /usr/bin/containerd exists; if not; we are probably running an older version
if [ ! -f /usr/bin/containerd ]
then
  # /usr/bin/containerd doesn't exist; expect that it is packaged with the engine
  CONTAINERD_PID="$(pgrep docker-containerd || true)"
  if [ -f "/var/run/docker/libcontainerd/docker-containerd.pid" ] && [ -z "${CONTAINERD_PID}" ]
  then
    # pid file exists and containerd isn't running
    echo -n "INFO: Removing stale pid file (/var/run/docker/libcontainerd/docker-containerd.pid)..."
    rm /var/run/docker/libcontainerd/docker-containerd.pid
    echo "done"
  fi
else
  # /usr/bin/containerd exists; we should start containerd because docker will start it differently than systemd would have
  echo "INFO: Starting containerd..."
  /usr/bin/containerd &

  # wait to make sure containerd starts
  while [ ! -S "/run/containerd/containerd.sock" ]
  do
    # wait until the containerd socket exists
    sleep .25
  done
  echo "INFO: containerd started successfully"
fi

echo "INFO: Executing CMD: ${*}"
exec "${@}"
