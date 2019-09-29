Build a [Debian 'buster' 10](https://www.debian.org/) image for the [Orange Pi Zero](http://www.orangepi.org/orangepizero/).

This project uses Docker (sorry) as many users may not wish to run Debian or drop an entire cross compiling development environment onto their workstation.  The target audiences are "just give me a stock Debian image" and those wishing to know "how do I build my own images from scratch?"

## TODO

 * need to include `fsck.ext4` in first initramfs build
   * `Warning: couldn't identify filesystem type for fsck hook, ignoring`
   * [looks like this, but suggested fix seems not to work](https://isolated.site/2019/02/17/update-initramfs-fails-to-include-fsck-in-initrd/)
 * test the watchdog
   * create a networking watchdog too as apparently the wifi driver is awful
 * clean up old logs and anything that leaked in from the build process

## Related Links

 * [Debian 9 (Stretch) SD card image for Orange Pi Zero](https://github.com/hjc4869/debian-stretch-orange-pi-zero)
 * [Cunning use of docker to run second stage of `debootstrap`](https://stackoverflow.com/a/55170186)
 * [Allwinner xradio driver](https://github.com/fifteenhex/xradio)

# Pre-flight

 * [Docker](https://docs.docker.com/install/), sorry...!
 * [`binfmt_misc`](https://en.wikipedia.org/wiki/Binfmt_misc) support on the host, and loaded (`modprobe binfmt_misc`)
 * [QEMU User Mode](https://ownyourbits.com/2018/06/13/transparently-running-binaries-from-any-architecture-in-linux-with-qemu-and-binfmt_misc/)

## Debian

    echo 'deb [arch=amd64] https://download.docker.com/linux/debian buster stable' > /etc/apt/sources.list.d/docker.list
    sudo apt-get update
    sudo apt-get -yy install --no-install-recommends binfmt-support docker-ce qemu-user-static

# Build

    sh build.sh

After a while, downloading ~500MB plus roughly 15 mins, the project should emit a file called `debian-orange-pi-zero.img`.

To use it, insert your SD card and copy the image to it using:

    sudo dd if=debian-orange-pi-zero.img bs=1M of=/dev/...

**N.B.** replace `/dev/...` with the path to your SD card, for example `/dev/sdc`.

This will take about 30 seconds, depending on how fast your SD card is.

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
