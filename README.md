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

After a while (downloading ~500MB plus roughly 10 mins), you should be left with a file called `debian-9-orange-pi-zero.img`.

If you insert your SD card, you can burn it to it with:

    dd if=debian-9-orange-pi-zero.img bs=1M of=/dev/...

**N.B.** replace `/dev/...` with the path to your SD card (for example `sdc`)
