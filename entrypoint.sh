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

# start containerd because docker will start it differently than systemd would have
/usr/bin/containerd &

# wait to make sure containerd starts
while [ ! -S "/run/containerd/containerd.sock" ]
do
  sleep .25
done

exec "${@}"
