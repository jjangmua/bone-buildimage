ARCH = arm
MACHINE = ti_bone
MACHINE_PREFIX = $(MACHINE)-r0
PLATFORM  = $(ARCH)-$(MACHINE_PREFIX)

PWD = $(shell pwd)
IMAGE_TARBALL = ubuntu-18.04.3-minimal-armhf-2020-02-10.tar.xz
IMAGE_TARBALL_URLS = https://rcn-ee.com/rootfs/eewiki/minfs/$(IMAGE_TARBALL)
ROOTFS_TARBALL = armhf-rootfs-ubuntu-bionic.tar
INSTALLER_DIR = $(PWD)/installer
SCRIPT_DIR = $(PWD)/scripts
ROOTFS_DIR = $(PWD)/rootfs
DOWNLOAD_DIR = $(PWD)/download
OVERLAY_DIR = $(PWD)/overlay

ROOTFS_CPIO = $(PWD)/sysroot.cpio
ROOTFS_CPIO_XZ = $(PWD)/$(PLATFORM).initrd
OUTPUT_BIN = $(PWD)/onie-installer-$(PLATFORM).bin

all:
	@if ! [ "$(shell id -u)" = 0 ]; then \
		echo "This script must be run as root"; \
		exit 1; \
	fi

	@rm -rf $(ROOTFS_DIR)
	@echo "==== Extracting Beaglebone rootfs ===="
	@if [ ! -d $(ROOTFS_DIR) ]; then \
		wget -nc $(IMAGE_TARBALL_URLS) -P $(DOWNLOAD_DIR); \
		mkdir -p $(ROOTFS_DIR); \
		tar xf $(DOWNLOAD_DIR)/$(IMAGE_TARBALL) -C $(DOWNLOAD_DIR); \
		fakeroot tar xf $(DOWNLOAD_DIR)/$$(basename $(IMAGE_TARBALL) .tar.xz)/$(ROOTFS_TARBALL) -C $(ROOTFS_DIR); \
	fi

	@echo "==== Init $(PLATFORM) rootfs ===="
	@cp -rf /usr/bin/qemu-arm-static $(ROOTFS_DIR)/usr/bin
	@cp -rf $(SCRIPT_DIR)/init-rootfs.sh $(ROOTFS_DIR)
	@mount -o bind /dev $(ROOTFS_DIR)/dev
	@mount -t devpts none $(ROOTFS_DIR)/dev/pts
	@mount -t sysfs none $(ROOTFS_DIR)/sys

	@chroot $(ROOTFS_DIR) ./init-rootfs.sh

	@rm -rf $(ROOTFS_DIR)/usr/bin/qemu-arm-static
	@rm -rf $(ROOTFS_DIR)/init-rootfs.sh
	@umount -n $(ROOTFS_DIR)/dev/pts
	@umount -n $(ROOTFS_DIR)/dev
	@umount -n $(ROOTFS_DIR)/sys

	@echo "==== Copy overlay file to $(PLATFORM) rootfs ===="
	@cp -vrf $(OVERLAY_DIR)/* $(ROOTFS_DIR);

	@echo "==== Create xz compressed $(PLATFORM) rootfs ===="
	@fakeroot -- $(SCRIPT_DIR)/make-sysroot.sh $(ROOTFS_DIR) $(ROOTFS_CPIO)
	@xz --compress --force --check=crc32 --stdout -8 $(ROOTFS_CPIO) > $(ROOTFS_CPIO_XZ)

	@echo "==== Create $(PLATFORM) OS self-extracting archive ===="
	@$(SCRIPT_DIR)/onie-mk-demo.sh u-boot-arch $(MACHINE) $(PLATFORM) \
		$(INSTALLER_DIR) $(PWD)/platform.conf $(OUTPUT_BIN) OS $(ROOTFS_CPIO_XZ)

clean:
	@rm -rf $(ROOTFS_CPIO_XZ)
	@rm -rf $(OUTPUT_BIN)
	@rm -rf $(ROOTFS_CPIO)
	@rm -rf $(ROOTFS_DIR)