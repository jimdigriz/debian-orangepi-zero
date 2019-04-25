#!/bin/sh

set -eux

SIZE=$(($(du -sm rootfs | cut -f1) * 11 / 10))

dd of=debian-orange-pi-zero.img if=/dev/zero bs=1M count=0 seek=$SIZE
printf "label: dos\n\nstart=1M, type=83\n" | sfdisk debian-orange-pi-zero.img
dd of=debian-orange-pi-zero.img if=u-boot/u-boot-sunxi-with-spl.bin bs=1k seek=8 conv=notrunc

losetup -fP debian-orange-pi-zero.img
DEV=$(losetup | awk '/debian-orange-pi-zero.img/ { print $1 }')

mkfs.ext4 -L root ${DEV}p1

mkdir target

mount ${DEV}p1 target

# docker bind mounts in resolv.conf so we have to delay fixing this
ln -s -f -t rootfs/etc /run/systemd/resolve/resolv.conf

tar cC rootfs . | tar xC target

umount target

rmdir target

losetup -d $DEV

exit 0
