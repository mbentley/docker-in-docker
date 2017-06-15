#!/bin/sh

DOCKERD_RUNNING="$(pgrep dockerd > /dev/null 2>&1; echo $?)"
if [ -f "/var/run/docker.pid" ] && [ "${DOCKERD_RUNNING}" -eq "1" ]
then
  echo "Removing stale pid file (/var/run/docker.pid)..."
  rm  /var/run/docker.pid
fi

CONTAINERD_RUNNING="$(pgrep docker-containerd > /dev/null 2>&1; echo $?)"
if [ -f "/var/run/docker/libcontainerd/docker-containerd.pid" ] && [ "${CONTAINERD_RUNNING}" -eq "1" ]
then
  echo "Removing stale pid file (/var/run/docker/libcontainerd/docker-containerd.pid)..."
  rm /var/run/docker/libcontainerd/docker-containerd.pid
fi

exec "${@}"
