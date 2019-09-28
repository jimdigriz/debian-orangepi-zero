#!/bin/sh

set -eux

passwd -d root

systemctl enable resize-rootfs

systemctl enable systemd-networkd
systemctl enable systemd-resolved

chmod 0600 /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
systemctl enable wpa_supplicant@wlan0

echo g_serial >> /etc/modules
printf "# USB Serial Gadget\nttyGS0\n" >> /etc/securetty
systemctl enable serial-getty@ttyGS0

# xradio_wlan plumbing
depmod $(apt-cache depends linux-image-armmp | sed -n -e '/Depends/ s/.*linux-image-// p')

exit 0
