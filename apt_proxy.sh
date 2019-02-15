#!/bin/bash

set -e

if [ -n "${APT_PROXY}" ]
then
  echo -n "Setting apt proxy..."
  echo 'Acquire::http::Proxy "http://'"${APT_PROXY}"'";' > /etc/apt/apt.conf.d/00proxy
  echo "done"
else
  echo "No apt cache defined, skipping"
fi
