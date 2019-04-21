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

echo g_serial >> /etc/modules
printf "# USB Serial Gadget\nttyGS0\n" >> /etc/securetty
systemctl enable serial-getty@ttyGS0.service

systemctl enable resize-rootfs

exit 0
