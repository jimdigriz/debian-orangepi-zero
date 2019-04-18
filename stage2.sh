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
apt-get upgrade
apt-get -yy --option=Dpkg::options::=--force-unsafe-io install --no-install-recommends \
	linux-image-armmp/stretch-backports
apt-get clean
find /var/lib/apt/lists -type f -delete

passwd -d root

exit 0
