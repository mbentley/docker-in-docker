#!/bin/sh

DOCKERD_RUNNING="$(pgrep dockerd > /dev/null 2>&1; echo $?)"
if [ -f "/var/run/docker.pid" ] && [ "${DOCKERD_RUNNING}" -eq "1" ]
then
  echo "Removing stale pid file (/var/run/docker.pid)..."
  rm  /var/run/docker.pid
fi

# set mount propagation
if [ -n "${MOUNT_PROPAGATION}" ]
then
  for MOUNT in ${MOUNT_PROPAGATION}
  do
    echo "Mounting ${MOUNT} as 'rshared'..."
    mount --make-rshared "${MOUNT}"
  done
fi

# check to see if /usr/bin/containerd exists; if not; we are probably running an older version
if [ ! -f /usr/bin/containerd ]
then
  # /usr/bin/containerd doesn't exist; expect that it is packaged with the engine
  CONTAINERD_RUNNING="$(pgrep docker-containerd > /dev/null 2>&1; echo $?)"
  if [ -f "/var/run/docker/libcontainerd/docker-containerd.pid" ] && [ "${CONTAINERD_RUNNING}" -eq "1" ]
  then
    echo "Removing stale pid file (/var/run/docker/libcontainerd/docker-containerd.pid)..."
    rm /var/run/docker/libcontainerd/docker-containerd.pid
  fi
else
  # /usr/bin/containerd exists; we should start containerd because docker will start it differently than systemd would have
  /usr/bin/containerd &

  # wait to make sure containerd starts
  while [ ! -S "/run/containerd/containerd.sock" ]
  do
    sleep .25
  done
fi

# cgroup v2: enable nesting (from https://github.com/moby/moby/blob/v20.10.8/hack/dind#L28-L38)
if [ -f /sys/fs/cgroup/cgroup.controllers ]
then
  echo "cgroups v2 detected; enabling nesting"
  # move the processes from the root group to the /init group,
  # otherwise writing subtree_control fails with EBUSY.
  # An error during moving non-existent process (i.e., "cat") is ignored.
  mkdir -p /sys/fs/cgroup/init
  xargs -rn1 < /sys/fs/cgroup/cgroup.procs > /sys/fs/cgroup/init/cgroup.procs || :
  # enable controllers
  sed -e 's/ / +/g' -e 's/^/+/' < /sys/fs/cgroup/cgroup.controllers \
    > /sys/fs/cgroup/cgroup.subtree_control
fi

exec "${@}"
