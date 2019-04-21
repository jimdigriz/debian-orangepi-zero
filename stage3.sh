#!/bin/sh

set -eux

dd of=debian-orange-pi-zero.img if=/dev/zero bs=1M count=0 seek=512
printf "label: dos\n\nstart=1M, type=83\n" | sfdisk debian-orange-pi-zero.img
dd of=debian-orange-pi-zero.img if=u-boot/u-boot-sunxi-with-spl.bin bs=1k seek=8 conv=notrunc

losetup -fP debian-orange-pi-zero.img
DEV=$(losetup | awk '/debian-orange-pi-zero.img/ { print $1 }')

mkfs.ext4 -L root ${DEV}p1

mkdir target

mount ${DEV}p1 target

tar cC rootfs . | tar xC target
./u-boot/tools/mkimage -C none -A arm -T script -d target/boot/boot.cmd target/boot/boot.scr
cp u-boot/arch/arm/dts/sun8i-h2-plus-orangepi-zero.dtb target/boot

umount target

losetup -d $DEV

rmdir target

exit 0
