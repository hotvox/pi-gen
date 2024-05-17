#!/bin/bash -e


install -d  					            "${ROOTFS_DIR}/etc/systemd/system"
install -m 600  files/inputd.service	    "${ROOTFS_DIR}/etc/systemd/system/"
install -m 600  files/outputd.service	    "${ROOTFS_DIR}/etc/systemd/system/"
unzip -d        "${ROOTFS_DIR}/root/hotsat" files/hotsat.zip

on_chroot << EOF
systemctl enable inputd.service
systemctl enable outputd.service
EOF

echo "WPA_SSID=${WPA_SSID}"
echo "WPA_PASSWORD=${WPA_PASSWORD}"
# If WPA_SSID and WPA_PASSWORD are set, configure wlan
if [ -n "${WPA_SSID}" ] && [ -n "${WPA_PASSWORD}" ]; then
    echo "Configuring network"
	on_chroot <<- EOF
        echo "Running set_wlan"
		/usr/lib/raspberrypi-sys-mods/imager_custom set_wlan "${WPA_SSID}" "${WPA_PASSWORD}"
        echo "Enabling NetworkManager service"
        systemctl enable NetworkManager.service
	EOF
fi