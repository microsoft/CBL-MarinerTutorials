#!/bin/bash

echo "------------ Setting up Mariner Build Environment ------------"

# build variables
MARINER_BASE_DIR=/mariner
BUILD_DIR="$MARINER_BASE_DIR/build"
CCACHE_DIR="$MARINER_BASE_DIR/ccache"
CBL_MARINER_GIT_URL="https://github.com/microsoft/CBL-Mariner.git"
CHROOT_DIR="/temp/DockerStage/"
DISABLE_UPSTREAM_REPOS="n"
IMAGE_CONFIG_DIR="$MARINER_BASE_DIR/toolkit/imageconfigs"
LOG_LEVEL="info"
LOG_PUBLISH_DIR="$MARINER_BASE_DIR/logs"
MARINER_RELEASE_TAG="2.0-stable"
OUT_DIR="$MARINER_BASE_DIR/out"
RUN_CHECK="y"
SOURCE_URL="https://cblmarinerstorage.blob.core.windows.net/sources/core"
SPECS_DIR="$MARINER_BASE_DIR/SPECS"
USE_CCACHE="y"

# Build Mariner toolkit if not present, by cloning Mariner GitHub repo
#
# No arguments
# Global variables expected to be defined: BUILD_DIR, CHROOT_DIR, CHROOT_NB, OUT_DIR
download_mariner_toolkit() {
    if [ ! "$(ls -A toolkit)" ]; then
    echo "------------ Preparing Mariner toolkit ------------"
        if [ ! -d CBL-Mariner ]; then
            echo "------------ Cloning Mariner toolkit from github ------------"
            git clone \
                --branch ${MARINER_RELEASE_TAG} \
                --depth 1 \
                ${CBL_MARINER_GIT_URL}
        fi
        echo "------------ Building Mariner toolkit ------------"
        make -j$(nproc) \
            -C CBL-Mariner/toolkit \
            package-toolkit \
            BUILD_DIR="$BUILD_DIR" \
            CHROOT_DIR="$CHROOT_DIR" \
            CONCURRENT_PACKAGE_BUILDS="$CHROOT_NB" \
            CONFIG_FILE= \
            LOG_LEVEL=info \
            OUT_DIR="$OUT_DIR" \
            REBUILD_TOOLS=y && \
        rm -rf CBL-Mariner && \
        tar -xzvf ${OUT_DIR}/toolkit-*.tar.gz
    fi
}

# create chroot lock
pushd $CHROOT_DIR
touch chroot-pool.lock
CHROOT_NB=$(find . -maxdepth 1 -type d -name "docker-chroot-*" | wc -l)
CONCURRENT_PACKAGE_BUILDS=$CHROOT_NB
popd

# export build variables
export BUILD_DIR
export CBL_MARINER_GIT_URL
export CCACHE_DIR
export CHROOT_BASE_DIR
export CHROOT_DIR
export CHROOT_NB
export CONCURRENT_PACKAGE_BUILDS
export DISABLE_UPSTREAM_REPOS
export IMAGE_CONFIG_DIR
export LOG_LEVEL
export LOG_PUBLISH_DIR
export MARINER_BASE_DIR
export MARINER_RELEASE_TAG
export OUT_DIR
export RUN_CHECK
export SOURCE_URL
export SPECS_DIR
export USE_CCACHE

# install prerequisites
#----------------------
echo "------------ Installing Build Prerequisites ------------"

tdnf -y install \
        binutils \
        bison \
        ca-certificates \
        cdrkit \
        curl \
        dracut \
        dnf \
        dnf-utils \
        dosfstools \
        gawk \
        gcc \
        git \
        glibc-devel \
        golang \
        kernel-headers \
        lvm2 \
        make \
        parted \
        pigz \
        python3 \
        qemu-img \
        rpm \
        rpm-build \
        rsync \
        tdnf-plugin-repogpgcheck \
        tar \
        wget

go version

# clone toolkit from github and set up for Mariner build
pushd /mariner/
download_mariner_toolkit
popd

cd /mariner/toolkit/
