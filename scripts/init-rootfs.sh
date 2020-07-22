#!/bin/sh

export LC_ALL="en_US.UTF-8"

rm /etc/resolv.conf
ln -s /lib/systemd/resolv.conf /etc/resolv.conf
apt-get update
apt-get -y install --no-install-recommends linux-image-4.15.0-106-generic
apt-get -y install --no-install-recommends linux-modules-4.15.0-106-generic
apt-get -y install bash-completion
apt-get -y install minicom
apt-get -y install ser2net
apt-get -y install telnet
apt-get -y install vim
apt-get clean

ln -s /lib/firmware/4.15.0-106-generic/device-tree/am335x-bonegreen.dtb /dtb
rm -rf /initrd.img.old
rm -rf /vmlinuz.old
