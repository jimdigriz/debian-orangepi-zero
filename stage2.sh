#!/bin/sh

set -eux

sed -i.bak -e '/^\s*setup_proc$/ d' /debootstrap/suite-script
/debootstrap/debootstrap --second-stage

apt-get update
apt-get -yy --option=Dpkg::options::=--force-unsafe-io upgrade
apt-get -yy --option=Dpkg::options::=--force-unsafe-io install --no-install-recommends \
	linux-image-armmp/stretch-backports
apt-get clean
find /var/lib/apt/lists -type f -delete

passwd -d root

systemctl enable systemd-networkd.service
systemctl enable systemd-resolved.service

echo g_serial >> /etc/modules
printf "# USB Serial Gadget\nttyGS0\n" >> /etc/securetty
systemctl enable serial-getty@ttyGS0.service

VER=$(apt-cache depends linux-image-armmp | sed -n -e '/Depends/ s/.*linux-image-// p')
mkdir -p /lib/modules/$VER/misc
mv /tmp/xradio_wlan.ko /lib/modules/$VER/misc
depmod $VER

systemctl enable resize-rootfs.service

exit 0
