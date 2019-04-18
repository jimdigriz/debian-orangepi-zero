#!/bin/sh

set -eux

sed -i.bak -e '/^\s*setup_proc$/ d' /debootstrap/suite-script
/debootstrap/debootstrap --second-stage

cat <<'EOF' > /etc/apt/sources.list
deb http://deb.debian.org/debian/ stretch main contrib non-free
#deb-src http://deb.debian.org/debian/ stretch main contrib non-free

deb http://security.debian.org/debian-security stretch/updates main contrib non-free
#deb-src http://security.debian.org/debian-security stretch/updates main contrib non-free

# stretch-updates, previously known as 'volatile'
deb http://deb.debian.org/debian/ stretch-updates main contrib non-free
#deb-src http://deb.debian.org/debian/ stretch-updates main contrib non-free
EOF

cat <<'EOF' > /etc/apt/sources.list.d/debian-backports.list
deb http://deb.debian.org/debian stretch-backports main contrib non-free
#deb-src http://deb.debian.org/debian stretch-backports main contrib non-free
EOF

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

cat <<'EOF' > /etc/fstab
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system>	<mount point>	<type>	<options>		<dump>	<pass>
LABEL=root	/		auto	errors=remount-ro	0	1
EOF

cat <<'EOF' > /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

iface default inet dhcp
EOF

mkdir /etc/network/interfaces.d

cat <<'EOF' > /etc/network/interfaces.d/eth0
allow-hotplug eth0
iface eth0 inet dhcp
EOF

exit 0
