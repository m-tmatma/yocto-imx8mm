#!/bin/bash

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

cd $SCRIPT_DIR/xpi-imx8mm

COMPULAB_MACHINE=ucm-imx8m-mini
MACHINE=${COMPULAB_MACHINE} source sources/meta-bsp-imx8mm/tools/setup-imx8mm-env -b build-xwayland
