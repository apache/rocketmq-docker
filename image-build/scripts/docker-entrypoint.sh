#!/bin/bash
set -e

# Allow user specify custom CMD, maybe run /bin/bash to check the image
if [[ "$1" == "nameserver" || "${NODE_ROLE}" == "nameserver" ]]; then
  shift
  exec ./mqnamesrv "${@}"
elif [[ "$1" == "broker" || "${NODE_ROLE}" == "broker" ]]; then
  shift
  exec ./mqbroker "${@}"
elif [[ "$1" == "controller" || "${NODE_ROLE}" == "controller" ]]; then
  shift
  exec ./mqcontroller "${@}"
else
  # Run whatever command the user wants
  exec "$@"
fi
