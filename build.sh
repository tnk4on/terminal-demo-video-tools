#!/bin/bash
set -eu

# Repository Login
echo "### login to docker.io ###"
podman login docker.io

echo -e "\n### login to quay.io ###"
podman login quay.io

#export TAG=ffmpeg
export DOCKER=docker.io/tnk4on
export QUAY=quay.io/tnk4on
export ENVFILE=env

# Build all container images
CURDIR=$PWD
cd Containerfile.d

for f in Containerfile*
do
    echo -e "\n### Build multi-arch images for ${f/Containerfile./} ###"
    for ARCH in amd64 arm64
    do
        echo -e "\n#### podman build -t ${f/Containerfile./}:${ARCH} -f $f --build-arg ARCH=${ARCH} --platform linux/${ARCH} --manifest ${f/Containerfile./} . ####"
        podman build -t ${f/Containerfile./}:${ARCH} -f $f --build-arg ARCH=${ARCH} --platform linux/${ARCH} --manifest ${f/Containerfile./} .
    done
done

# Test

for f in Containerfile*
do
    echo -e "\n### Run ${f/Containerfile./} ###"
    for ARCH in amd64 arm64
    do
        echo -e "\n#### podman run --rm ${f/Containerfile./}:${ARCH} --version ####"
        podman run --rm ${f/Containerfile./}:${ARCH} --version
    done
done


# Push
## Docker.io
echo -e "\n### push to docker.io ###"
for f in Containerfile*
do
    echo -e "\n#### podman manifest push --all ${f/Containerfile./}:latest docker://${DOCKER}/${f/Containerfile./}:latest --format docker ###"
#    podman manifest push --all ${f/Containerfile./}:latest docker://${DOCKER}/${f/Containerfile./}:latest --format docker
done

### Quay.io
echo -e "\n### push to quay.io ###"
for f in Containerfile*
do
    echo -e "\n#### podman manifest push --all ${f/Containerfile./}:latest docker://${QUAY}/${f/Containerfile./}:latest ####"
#   podman manifest push --all ${f/Containerfile./}:latest docker://${QUAY}/${f/Containerfile./}:latest
done