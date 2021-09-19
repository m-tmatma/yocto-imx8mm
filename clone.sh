#!/bin/bash -e

BRANCHNAME=imx-linux-zeus
SCRIPT_DIR=$(cd $(dirname $0); pwd)

# Top dir of source
HOST_DOCKER_HOME=$SCRIPT_DIR/container/home/yocto
YOCTO_DIR=$HOST_DOCKER_HOME/xpi-imx8mm

REPO_PATH=$(which repo)
if [ -z "$REPO_PATH" ]; then
    echo "Please install google repo by 'sudo apt install -y repo' on ubuntu 20.10 or later."
    exit 1
fi

mkdir -p $YOCTO_DIR
cd $YOCTO_DIR

repo init -u git://source.codeaurora.org/external/imx/imx-manifest.git -b $BRANCHNAME -m imx-5.4.70-2.3.4.xml
repo sync -j$(nproc --all)
