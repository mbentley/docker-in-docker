#!/bin/bash

set -e

# set the container variable so that processes know we are in a docker container
export container=docker

DOCKERD_PID="$(pgrep dockerd || true)"
if [ -f "/var/run/docker.pid" ] && [ -z "${DOCKERD_PID}" ]
then
  # pid file exists and docker isn't running
  echo -n "INFO: removing stale pid file (/var/run/docker.pid)..."
  rm /var/run/docker.pid
  echo "done"
elif [ -n "${DOCKERD_RUNNING}" ]
then
  # docker is running
  echo "ERROR: docker is already running!"
  echo "  Hint: this script should only be executed as the container entrypoint!"
  exit 1
fi

# allow apparmor inside the container
if [ -d /sys/kernel/security ] && ! mountpoint -q /sys/kernel/security
then
  echo -n "INFO: mounting /sys/kernel/security as securityfs..."
  mount -t securityfs none /sys/kernel/security || {
    echo >&2 "WARN: could not mount /sys/kernel/security"
    echo >&2 "WARN: AppArmor detection and --privileged mode might break!"
  }
  echo "done"
fi

# set mount propagation for /
echo -n "INFO: mounting / as 'rshared'..."
mount --make-rshared /
echo "done"

# mount /tmp, if needed
if ! mountpoint -q /tmp
then
  echo -n "INFO: mounting /tmp with as tmpfs..."
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

  # loop to make sure this succeeds
  while ! {
    # move the processes from the root group to the /init group,
    # otherwise writing subtree_control fails with EBUSY.
    # An error during moving non-existent process (i.e., "cat") is ignored.
    xargs -rn1 < /sys/fs/cgroup/cgroup.procs > /sys/fs/cgroup/init/cgroup.procs || :
    # enable controllers
    sed -e 's/ / +/g' -e 's/^/+/' < /sys/fs/cgroup/cgroup.controllers \
      > /sys/fs/cgroup/cgroup.subtree_control
  }
  do
    # loop again!
    true
  done
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
    echo -n "INFO: removing stale pid file (/var/run/docker/libcontainerd/docker-containerd.pid)..."
    rm /var/run/docker/libcontainerd/docker-containerd.pid
    echo "done"
  fi
else
  # /usr/bin/containerd exists; we should start containerd because docker will start it differently than systemd would have
  echo "INFO: starting containerd..."
  /usr/bin/containerd &

  # wait to make sure containerd starts
  while [ ! -S "/run/containerd/containerd.sock" ]
  do
    # wait until the containerd socket exists
    sleep .25
  done
  echo "INFO: containerd started successfully"
fi

echo "INFO: executing CMD: ${*}"
exec "${@}"
