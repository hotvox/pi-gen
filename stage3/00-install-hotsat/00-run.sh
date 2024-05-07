#!/bin/bash -e

install -v -m 600 files/hotsat.zip	    "${ROOTFS_DIR}/root/"
install -v -d					        "${ROOTFS_DIR}/etc/systemd/system"
install -v -m 600 files/hotsat.service	"${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
unzip -d "${ROOTFS_DIR}"/root/hotsat.zip /root/hotsat
systemctl enable hotsat
EOF