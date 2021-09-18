#!/bin/bash
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
ACTION=$1
if [ -z "$ACTION" ]; then
    ACTION=build
fi

cd $SCRIPT_DIR/xpi-imx8mm

COMPULAB_MACHINE=ucm-imx8m-mini
MACHINE=${COMPULAB_MACHINE} source sources/meta-bsp-imx8mm/tools/setup-imx8mm-env -b build-xwayland

TARGET_SOURCE_MIRROR_DIR=/home/shared/SOURCE_MIRROR_URL
rm -f conf/site.conf

if [ -n "$REMOTE_SOURCE_MIRROR" ]; then
    echo SOURCE_MIRROR_URL = \"$REMOTE_SOURCE_MIRROR\"             >> conf/site.conf

    echo -----------------------------------------------------------
    echo MIRROR_URL is used
    echo $REMOTE_SOURCE_MIRROR
    echo -----------------------------------------------------------
else
    echo SOURCE_MIRROR_URL = \"file:///$TARGET_SOURCE_MIRROR_DIR\" >> conf/site.conf

    echo -----------------------------------------------------------
    echo local mirror is set
    echo $TARGET_SOURCE_MIRROR_DIR
    echo -----------------------------------------------------------
fi
echo INHERIT += \"own-mirrors\"                                >> conf/site.conf

if [ "$ACTION" = "makecache" ]; then
    echo DL_DIR = \"$TARGET_SOURCE_MIRROR_DIR\"                    >> conf/site.conf
    echo BB_GENERATE_MIRROR_TARBALLS = \"1\"                       >> conf/site.conf

    echo -----------------------------------------------------------
    echo makecache $TARGET_SOURCE_MIRROR_DIR
    echo -----------------------------------------------------------
fi

if [ "$ACTION" = "fetch" -o "$ACTION" = "makecache" ]; then
    bitbake core-image-minimal --runall=fetch -f
elif [ "$ACTION" = "build" ]; then
    bitbake meta-toolchain
else
	echo usage:
	echo $0 build
	echo $0 fetch
	echo $0 makecache
	exit 1
fi

if [ -n "$REMOTE_SOURCE_MIRROR" ]; then
    echo -----------------------------------------------------------
    echo remote mirror: $REMOTE_SOURCE_MIRROR
    echo -----------------------------------------------------------
else
    echo -----------------------------------------------------------
    echo local cache: target $TARGET_SOURCE_MIRROR_DIR
    echo local cache: host $HOST_SOURCE_MIRROR_URL
    if [ "$ACTION" = "makecache" ]; then
        echo created local cache at $TARGET_SOURCE_MIRROR_DIR
    fi
    echo -----------------------------------------------------------
fi
