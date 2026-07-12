#!/bin/bash
set -e

if [ -S /var/run/docker.sock ]; then
  echo "Waitong damon Docker (dind) ready..."
  timeout=60
  while ! docker info >/dev/null 2>&1; do
    timeout=$((timeout - 1))
    if [ "$timeout" -le 0 ]; then
      echo "Docker timeout" >&2
      exit 1
    fi
    sleep 1
  done
  echo "Docker ready."
fi

cd /home/runner
exec ./run.sh

