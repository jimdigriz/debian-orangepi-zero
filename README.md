Build a [Debian 'bullseye' 11](https://www.debian.org/) image for the [Orange Pi Zero](http://www.orangepi.org/orangepizero/).

This project uses Docker (sorry) as many users may not wish to run Debian or drop an entire cross compiling development environment onto their workstation.  The target audiences are "just give me a stock Debian image" and those wishing to know "how do I build my own images from scratch?"

## TODO

 * need to include `fsck.ext4` in first initramfs build
   * `Warning: couldn't identify filesystem type for fsck hook, ignoring`
   * [looks like this, but suggested fix seems not to work](https://isolated.site/2019/02/17/update-initramfs-fails-to-include-fsck-in-initrd/)

## Related Links

 * [Debian 9 (Stretch) SD card image for Orange Pi Zero](https://github.com/hjc4869/debian-stretch-orange-pi-zero)
 * [Cunning use of docker to run second stage of `debootstrap`](https://stackoverflow.com/a/55170186)
 * [Allwinner xradio driver](https://github.com/dbeinder/xradio.git)

# Pre-flight

 * [Docker](https://docs.docker.com/install/), sorry...!
 * [`binfmt_misc`](https://en.wikipedia.org/wiki/Binfmt_misc) support on the host, and loaded (`modprobe binfmt_misc`)
 * [QEMU User Mode](https://ownyourbits.com/2018/06/13/transparently-running-binaries-from-any-architecture-in-linux-with-qemu-and-binfmt_misc/)

## Debian/Ubuntu

    . /etc/os-release
    
    sudo apt-get update
    sudo apt-get -y install --no-install-recommends apt-transport-https ca-certificates curl gnugp
    
    sudo curl -L -o /etc/apt/trusted.gpg.d/docker.gpg.asc https://download.docker.com/linux/$ID/gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/docker.gpg.asc] https://download.docker.com/linux/$ID $VERSION_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    
    sudo apt-get update
    sudo apt-get -y install --no-install-recommends binfmt-support docker-ce qemu-user-static
    
    sudo usermod -a -G docker $(id -u -n)

**N.B.** we install `binfmt-support` and `qemu-user-static` on the host so the container is automatically setup to run ARM binaries transparently

**N.B.** `docker-ce` install instructions come from [Docker's website](https://docs.docker.com/engine/install/debian/)

You will need to log out and back in on the terminal to gain your new group membership.

# Build

    sh build.sh

After a while, downloading ~500MB plus roughly 15 mins, the project should emit a file called `debian-orange-pi-zero.img`.

To use it, insert your SD card and copy the image to it using:

    sudo dd if=debian-orange-pi-zero.img bs=1M of=/dev/...

**N.B.** replace `/dev/...` with the path to your SD card, for example `/dev/sdc`.

This will take about 30 to 300 seconds, depending on how fast your SD card is.

Once complete you can pop out the SD card from your workstation and put it in your Orange Pi Zero.

# Usage

Real [serial port access is strongly recommended](http://linux-sunxi.org/Xunlong_Orange_Pi_Zero#Adding_a_serial_port) as it will help with debugging and resolving problems, though if all you want is to use rather than develop the build process (ie. this project) you can though slum it with [USB serial gadget](http://linux-sunxi.org/USB_Gadget/Serial) access alone.

 * the root filesystem will [automatically grow to fill the SD card on first boot](https://copyninja.info/blog/grow_rootfs.html)
 * there is no password for the `root` user, so you can log in trivially with the serial console
 * though `systemd-timesyncd` should automatically handle this for you, if you are too quick typing `apt-get update` you may find you need to fix up the current date time with `date -s 2019-09-25`
 * networking is configured through [`systemd-networkd`](https://wiki.archlinux.org/index.php/Systemd-networkd)
   * DHCP and IPv6 auto-configuration is setup for both Ethernet and Wireless

This is a stock regular no-frills Debian installation, of significant note is that it does not have an SSH server and you will need to manually configured the wireless networking to match your needs.

## Wireless

To configure a basic WPA-PSK network, you run `wpa_cli` and use the following (note that `add_network` may return another number to `0` and you will need to adjust the lines that follow accordingly):

    > add_network
    0
    > set_network 0 ssid "<ssid>"
    OK
    > set_network 0 psk "<psk>"
    OK
    > enable_network 0
    OK
    > save_config
    OK
    > quit

## Upgrading

### Kernel

Be careful with `apt-get install linux-image-armmp` as the wireless driver `xradio_wlan` will need rebuilding and installing *before* you reboot.

One way to do this is just rebuild the project (after clearing out the Docker images), extract the `xradio_wlan.ko` driver with:

    docker run --rm opi0-stage3 cat xradio/xradio_wlan.ko > xradio_wlan.ko

Now copy it to your Orange Pi Zero's `/lib/modules/<VERSION>/extra/` and run `depmod -a <VERSION>` (for example where `<VERSION>` is `4.19.0-16-armmp`).

### u-boot

Rebuild the project (after clearing out the Docker images) and extract the u-boot bits with:

    docker run --rm opi0-stage1 cat u-boot/u-boot-sunxi-with-spl.bin > u-boot-sunxi-with-spl.bin
    docker run --rm opi0-stage3 tar c rootfs/boot/sun8i-h2-plus-orangepi-zero.dts rootfs/boot/sun8i-h2-plus-orangepi-zero.dtb rootfs/boot/boot.cmd rootfs/boot/boot.scr > u-boot.tar

Copy `u-boot-sunxi-with-spl.bin` and `u-boot.tar` to your Orange Pi Zero's and run from there:

    dd of=/dev/mmcblk0 if=u-boot-sunxi-with-spl.bin bs=1k seek=8 conv=notrunc
    tar -C / --strip-components=1 -xf u-boot.tar
