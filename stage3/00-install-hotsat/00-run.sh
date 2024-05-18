#!/bin/bash -e

. "${BASE_DIR}/config"
on_chroot << EOF
echo -n "${FIRST_USER_NAME:='hv'}:" > /boot/userconf.txt
openssl passwd -5 "${FIRST_USER_PASS:='hv'}" >> /boot/userconf.txt
touch /boot/ssh

echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
export DEBIAN_FRONTEND=noninteractive
EOF

install -m 644 files/config.txt "${ROOTFS_DIR}/boot/"
install -m 644 files/cmdline.txt "${ROOTFS_DIR}/boot/"

HOME="${ROOTFS_DIR}/home/${FIRST_USER_NAME}"
install -m 755 -o 1000 -g 1000 files/kiosk.sh "${HOME}/"
install -m 755 -o 1000 -g 1000 files/firstrun.sh "${HOME}/"
install -m 644 -o 1000 -g 1000 files/.profile "${HOME}/"
install -m 644 -o 1000 -g 1000 files/.xinitrc "${HOME}/"
install -m 644 -o 1000 -g 1000 files/.hushlogin "${HOME}/"
install -m 755 -o 1000 -g 1000 files/splash.png "${HOME}/"
install -m 755 -o 1000 -g 1000 files/hotvox-device_1.0.0_arm64.deb "${HOME}/"
install -m 755 -o 1000 -g 1000 -d "${HOME}/bin/"
install -m 755 -o 1000 -g 1000 files/bin/browser "${HOME}/bin/"

# Enable Auto-Login
on_chroot << OUTER_EOF
echo "Enabling Auto-Login"
systemctl set-default multi-user.target
cat > /etc/systemd/system/getty@tty1.service.d/override.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin ${FIRST_USER_NAME} --noclear %I \$TERM
EOF
OUTER_EOF

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

# install hotvox-device_1.0.0_amd64.deb located at ${HOME}
on_chroot << EOF
apt-get install -y chromium
dpkg -i /home/${FIRST_USER_NAME}/hotvox-device_1.0.0_arm64.deb
apt-get install -f -y
EOF