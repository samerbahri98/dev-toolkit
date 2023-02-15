#! /usr/bin/env sh

docker run --rm -it\
    -v "$(dirname "$SSH_AUTH_SOCK")":"$(dirname "$SSH_AUTH_SOCK")"\
    -v /var/run/docker.sock:/var/run/docker.sock\
    -v "$PWD":/ansible \
    -e SSH_AUTH_SOCK="$SSH_AUTH_SOCK" \
    -e KUBECONFIG=/ansible/.kube/config \
    --privileged \
    --add-host=host.docker.internal:host-gateway \
    --network host \
    -w /ansible \
    ansible-execution-env:latest /bin/bash