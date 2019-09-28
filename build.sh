#!/bin/sh

set -eux

docker build -t opi0-stage1 -f Dockerfile.stage1 .

docker build -t opi0-stage2 -f Dockerfile.stage2 .

docker run -it --name opi0-stage2b opi0-stage2
docker commit opi0-stage2b opi0-stage2b
docker rm opi0-stage2b >/dev/null

docker build -t opi0-stage3 -f Dockerfile.stage3 .

docker run -it --name opi0-stage3b --cap-add SYS_ADMIN --privileged -v /dev/:/dev opi0-stage3
docker cp opi0-stage3b:debian-orange-pi-zero.img .
docker rm opi0-stage3b >/dev/null

exit 0
