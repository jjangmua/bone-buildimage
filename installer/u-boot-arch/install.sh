#!/bin/sh

#  Copyright (C) 2014,2015 Curt Brune <curt@cumulusnetworks.com>
#  Copyright (C) 2015 david_yang <david_yang@accton.com>
#
#  SPDX-License-Identifier:     GPL-2.0

set -e

cd $(dirname $0)
. ./machine.conf

installer_dir=$(pwd)

echo "ONIE NOS Installer: platform: $platform"

create_partition() {
	fdisk /dev/mmcblk1 <<EOF
o
n
p
1
315

p
w
EOF
	mkfs.ext4 /dev/mmcblk1p1
}

install_uimage() {
	echo "Installing $platform rootfs"
	create_partition
	mkdir /tmpfs
	mount -t ext4 /dev/mmcblk1p1 /tmpfs
	cd /tmpfs && xz -dc < $installer_dir/arm-ti_bone-r0.initrd | cpio -idm && cd /
	sync
	umount /tmpfs
}

. ./platform.conf

install_uimage

echo "Updating U-Boot environment variables"
(cat <<EOF
nos_initargs setenv bootargs console=\$consoledev,\$baudrate root=/dev/mmcblk1p1 rw rootfstype=ext4;
nos_bootcmd ext4load mmc 1:1 \$kernel_addr_r /vmlinuz; ext4load mmc 1:1 \$fdt_addr_r /dtb; run nos_initargs; bootz \$kernel_addr_r - \$fdt_addr_r;
EOF
) > /tmp/env.txt

fw_setenv -s /tmp/env.txt

cd /

# Set NOS mode if available.  For manufacturing diag installers, you
# probably want to skip this step so that the system remains in ONIE
# "installer" mode for installing a true NOS later.
if [ -x /bin/onie-nos-mode ] ; then
    /bin/onie-nos-mode -s
fi
