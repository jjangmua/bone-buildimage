# ONIE Ubuntu 18.04 LTS Installer for Beaglebone

## Build Instruction
```
$ git clone https://github.com/jjangmua/bone-buildimage.git
$ cd bone-buildimage/
$ sudo make (root permission required)
```
Once the compile has been finished you will be found the output file on bone-buildimage/ directory
* onie-installer-arm-ti_bone-r0.bin

## Installation
1. Copy onie-installer-arm-ti_bone-r0.bin to SD card and plugged in Beagle board
2. Bootup to onie_rescue
3. Mount SD card
```
ONIE:/ # mkdir /media
ONIE:/ # mount /dev/mmcblk0p1 /media
```
4. Install Ubuntu 18.04 LTS
```
ONIE:/ # cd /media/
ONIE:/ # onie-nos-install onie-installer-arm-ti_bone-r0.bin

```

After the installation has been completed, the system will automatic bootup to ubuntu OS when the board has power on, or you can manually by run "run nos_bootcmd" command in the uboot
