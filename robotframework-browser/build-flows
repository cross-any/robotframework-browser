#!/bin/bash
set -e
set -x
pushd $(dirname $0)/../
for f in */step.yaml; do
  image=$(grep image: $f|awk '{print $2}')
  pushd $(dirname $f)
  if [ -e Dockerfile ]; then
    docker build -t $image -f Dockerfile ..
    docker push $image
  fi
  popd
done
popd
