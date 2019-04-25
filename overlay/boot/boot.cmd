ext4load mmc 0 ${fdt_addr_r} /boot/${fdtfile}
ext4load mmc 0 ${kernel_addr_r} vmlinuz
ext4load mmc 0 ${ramdisk_addr_r} initrd.img
setenv bootargs console=ttyS0,115200 console=ttyGS0,115200 earlyprintk initrd=${ramdisk_addr_r},32M root=/dev/mmcblk0p1 panic=10
bootz ${kernel_addr_r} - ${fdt_addr_r}
