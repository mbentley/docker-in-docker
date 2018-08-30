#!/bin/sh

containerd &
/usr/libexec/containerd-offline-installer /var/lib/containerd-offline-installer/runc.tar docker.io/docker/runc
/usr/libexec/containerd-offline-installer /var/lib/containerd-offline-installer/containerd-shim-process.tar docker.io/docker/containerd-shim-process
kill "$(pidof containerd)"
