#!/bin/bash -e


install -d  					            "${ROOTFS_DIR}/etc/systemd/system"
install -m 600  files/inputd.service	    "${ROOTFS_DIR}/etc/systemd/system/"
install -m 600  files/outputd.service	    "${ROOTFS_DIR}/etc/systemd/system/"
unzip -d        "${ROOTFS_DIR}/root/hotsat" files/hotsat.zip

on_chroot << EOF
systemctl enable inputd
systemctl enable outputd
EOF

# If WPA_SSID and WPA_PASSWORD are set, configure wlan
if [ -v WPA_SSID ] && [ -v WPA_PASSWORD ]; then
	on_chroot <<- EOF
		/usr/lib/raspberrypi-sys-mods/imager_custom set_wlan "${WPA_SSID}" "${WPA_PASSWORD}"
	EOF
fi