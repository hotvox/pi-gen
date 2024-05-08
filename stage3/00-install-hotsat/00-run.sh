#!/bin/bash -e


install -d  					            "${ROOTFS_DIR}/etc/systemd/system"
install -m 600  files/inputd.service	    "${ROOTFS_DIR}/etc/systemd/system/"
install -m 600  files/outputd.service	    "${ROOTFS_DIR}/etc/systemd/system/"
unzip -d        "${ROOTFS_DIR}/root/hotsat" files/hotsat.zip

on_chroot << EOF
systemctl enable inputd
systemctl enable outputd
EOF