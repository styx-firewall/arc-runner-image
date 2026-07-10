#!/bin/bash
set -e

# Si hay un socket de Docker montado (contenedor dind sidecar), espera a que responda
if [ -S /var/run/docker.sock ]; then
  echo "Esperando a que el daemon Docker (dind) esté listo..."
  timeout=60
  while ! docker info >/dev/null 2>&1; do
    timeout=$((timeout - 1))
    if [ "$timeout" -le 0 ]; then
      echo "Docker no respondió a tiempo" >&2
      exit 1
    fi
    sleep 1
  done
  echo "Docker listo."
fi

cd /home/runner
exec ./run.sh

