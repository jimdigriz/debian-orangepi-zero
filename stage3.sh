#!/bin/sh

set -eux

dd of=debian-9-orange-pi-zero.img if=/dev/zero bs=1M count=0 seek=512
printf "label: dos\n\nstart=1M, type=83\n" | sfdisk debian-9-orange-pi-zero.img
dd of=debian-9-orange-pi-zero.img if=u-boot/u-boot-sunxi-with-spl.bin bs=1k seek=8 conv=notrunc

losetup -fP debian-9-orange-pi-zero.img

mkfs.ext4 -L root /dev/loop0p1

mkdir target

mount /dev/loop0p1 target

tar -cC rootfs . | tar -xC target
cp u-boot/arch/arm/dts/sun8i-h2-plus-orangepi-zero.dtb target/boot

umount target

losetup -d $(losetup | awk '/debian-9-orange-pi-zero.img/ { print $1 }')

rmdir target

exit 0
