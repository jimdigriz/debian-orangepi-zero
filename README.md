Build a [Debian 'stretch' 9](https://www.debian.org/) image for the [Orange Pi Zero](http://www.orangepi.org/orangepizero/).

This project uses Docker (sorry), my justification is that people may not run Debian or drop an entire cross compiling development environment onto their workstation.

## Related Links

 * [Debian 9 (Stretch) SD card image for Orange Pi Zero](https://github.com/hjc4869/debian-stretch-orange-pi-zero)
 * [cunning](https://stackoverflow.com/a/55170186)

# Pre-flight

 * [Docker](https://docs.docker.com/install/), sorry...!
 * `binfmt_misc` support on the host, and loaded (`modprobe binfmt_misc`)
 * `sudo apt-get install --no-install-recommends binfmt-support qemu-user-static`

# Build

    sh build.sh

After a while (downloading ~500MB plus roughly 15 mins), you should be left with a file called `debian-orange-pi-zero.img`.

To use it, insert your SD card and copy the image to it using:

    dd if=debian-orange-pi-zero.img bs=1M of=/dev/...

**N.B.** replace `/dev/...` with the path to your SD card (for example `sdc`)

This will take about 30 seconds, depending on how fast your SD card is.

Once complete you can pop out the SD card from your workstation and put it in your Orange Pi Zero.

# Usage

Real [serial port access is strongly recommended](http://linux-sunxi.org/Xunlong_Orange_Pi_Zero#Adding_a_serial_port) as it will help with debugging and resolving problems, though if all you want is to use rather than develop the build process (ie. this project) you can though slum it with [USB serial gadget](http://linux-sunxi.org/USB_Gadget/Serial) access alone.

 * there is no password for the `root` user, so you can log in trivially with the serial console
