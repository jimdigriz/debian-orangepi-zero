#!/bin/sh

set -eu

docker build -t opi0-stage1 -f Dockerfile.stage1 \
	--build-arg xradio=https://github.com/jimdigriz/xradio.git \
	--build-arg xradio_branch=debug-ifdefs .

docker build -t opi0-stage2 -f Dockerfile.stage2 .

ID=$(docker create opi0-stage2)
docker start -a $ID
docker commit $ID opi0-stage2b
docker rm $ID

docker build -t opi0-stage3 -f Dockerfile.stage3 .

ID=$(docker create --cap-add SYS_ADMIN --privileged -v /dev/:/dev opi0-stage3)
docker start -a $ID
docker cp $ID:debian-orange-pi-zero.img .
docker rm $ID >/dev/null

exit 0
