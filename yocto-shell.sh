#!/bin/bash -e

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
source ${SCRIPT_DIR}/common-variable.sh

HOST_DOCKER_HOME=$SCRIPT_DIR/container/home/yocto
TARGET_HOME=/home/yocto

REMOTE_URL=$(git remote get-url origin)
BRANCH_NAME=$(git name-rev --name-only HEAD | sed "s/\W/_/g")
CONTAINER_NAME=$(basename $REMOTE_URL)--${BRANCH_NAME}--$(basename $SCRIPT_DIR)__$(git rev-parse --short HEAD)__$(date "+%Y%m%d-%H%M%S")

HOST_DOCKER_OPT=$SCRIPT_DIR/container/opt
TARGET_OPT=/opt

HOST_SSTATE_DIR=$HOME/shared/$IMAGEBASE/sstate-cache
# HOST_DL_DIR=$HOME/shared/$IMAGEBASE/downloads
TARGET_SSTATE_DIR=/home/shared/sstate-cache
# TARGET_DL_DIR=/home/shared/downloads
HOST_SOURCE_MIRROR_URL=$HOME/shared/$IMAGEBASE/SOURCE_MIRROR_URL
TARGET_SOURCE_MIRROR_URL=/home/shared/SOURCE_MIRROR_URL

mkdir -p $HOST_DOCKER_HOME
mkdir -p $HOST_DOCKER_OPT
# mkdir -p $HOST_SSTATE_DIR
# mkdir -p $HOST_DL_DIR
mkdir -p $HOST_SOURCE_MIRROR_URL

COMMAND_ARG=$1
if [ x$COMMAND_ARG = x"build" -o  x$COMMAND_ARG = x"fetch"  -o  x$COMMAND_ARG = x"makecache" ] ; then
	COMMAND_LINE="$TARGET_HOME/build-yocto.sh $COMMAND_ARG"
	ADDITIONAL_OPT=
	X11OPTIONS=
elif [ x$COMMAND_ARG = x"shell" ] ; then
	COMMAND_LINE=/bin/bash
	ADDITIONAL_OPT=-it

	if [ x$DISPLAY = x'' ] ; then
		X11OPTIONS=
	else
		X11OPTIONS="-e DISPLAY=unix${DISPLAY} -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/.Xauthority:/root/.Xauthority"

		xhost +local:
	fi
else
	echo usage:
	echo $0 build
	echo $0 shell
	echo $0 fetch
	echo $0 makecache
	exit 0
fi

docker run $ADDITIONAL_OPT --rm -u yocto:yocto \
	--name $CONTAINER_NAME \
	-e REMOTE_SOURCE_MIRROR=$REMOTE_SOURCE_MIRROR \
	-e HOST_SOURCE_MIRROR_URL=$HOST_SOURCE_MIRROR_URL \
	-v $HOST_SSTATE_DIR:$TARGET_SSTATE_DIR \
	-v $HOST_DOCKER_OPT:$TARGET_OPT \
	-v $HOST_SOURCE_MIRROR_URL:$TARGET_SOURCE_MIRROR_URL \
	-v $HOST_DOCKER_HOME:$TARGET_HOME \
	$X11OPTIONS -w $TARGET_HOME $DOCKERIMAGE $COMMAND_LINE
