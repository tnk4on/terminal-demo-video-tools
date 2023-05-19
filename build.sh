#
# If you do not need to push container images, comment out the registry login settings and the push section
#

#!/bin/bash
set -eu

# Registry Login
echo "### login to docker.io ###"
podman login docker.io

echo -e "\n### login to quay.io ###"
podman login quay.io

#　Set up for your Container Registry account
export DOCKER=docker.io/tnk4on
export QUAY=quay.io/tnk4on

# Build all container images
CURDIR=$PWD
cd Containerfile.d

for f in Containerfile*
do
    TAG=${f/Containerfile./}
    echo -e "\n### Build multi-arch images for ${TAG} ###"
    for ARCH in amd64 arm64
    do
        echo -e "\n#### podman build -t ${TAG}:${ARCH} -f $f --build-arg ARCH=${ARCH} --platform linux/${ARCH} --manifest ${TAG} . ####"
        podman build -t ${TAG}:${ARCH} -f $f --build-arg ARCH=${ARCH} --platform linux/${ARCH} --manifest ${TAG} .
    done
done

# Test
for f in Containerfile*
do
    TAG=${f/Containerfile./}
    echo -e "\n### Run ${TAG} ###"
    for ARCH in amd64 arm64
    do
        echo -e "\n#### podman run --rm ${TAG}:${ARCH} --version ####"
        podman run --rm ${TAG}:${ARCH} --version
    done
done


# Push to registry
## Docker.io
echo -e "\n### push to docker.io ###"
for f in Containerfile*
do
    TAG=${f/Containerfile./}
    echo -e "\n#### podman manifest push --all ${TAG}:latest docker://${DOCKER}/${TAG}:latest --format docker ###"
    podman manifest push --all ${TAG}:latest docker://${DOCKER}/${TAG}:latest --format docker
done

### Quay.io
echo -e "\n### push to quay.io ###"
for f in Containerfile*
do
    TAG=${f/Containerfile./}
    echo -e "\n#### podman manifest push --all ${TAG}:latest docker://${QUAY}/${TAG}:latest ####"
    podman manifest push --all ${TAG}:latest docker://${QUAY}/${TAG}:latest
done

echo "done."
cd $CURDIR