#!/bin/sh

set -eu

docker build -t opi-stage1 -f Dockerfile.stage1 .

docker build -t opi-stage2 -f Dockerfile.stage2 .

ID=$(docker create opi-stage2)
docker start -a $ID
docker commit $ID opi-stage2b
docker rm $ID

docker build -t opi-stage3 -f Dockerfile.stage3 .

ID=$(docker create --cap-add SYS_ADMIN --privileged -v /dev/:/dev opi-stage3)
docker start -a $ID
docker cp $ID:debian-9-orange-pi-zero.img .
docker rm $ID

exit 0
