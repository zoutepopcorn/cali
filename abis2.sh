#!/bin/bash
#
##
###
###        _     _         ____
###   __ _| |__ (_)___    |___ \
###  / _` | '_ \| / __|     __) |
### | (_| | |_) | \__ \    / __/
###  \__,_|_.__/|_|___/___|_____|
###                  |_____|
###  _ _|_ _ ._    _  _  
### (_\/|_(_)|_)\/(_|(/_ 
###   /      |  /  _|                     
###
### abis_2
### arch base installation script_2
### post arch-chroot
### (c) 2019 by cytopyge
###
##
#

#
##
## after executing abis in the new environment manually:
## arch-chroot /mnt
## pacman -Sy git
## git clone https://github.com/cytopyge/arch_installation
##sh arch_installation/abis.sh
##
#

## time settings
ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc
sed -i "/^#en_US.UTF-8 UTF-8/c\en_US.UTF-8 UTF-8" /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

## network configuration
## create the hostname file
echo -n 'Enter hostname? '
read hostname
echo "$hostname" > /etc/$hostname
## add matching entries to hosts file
echo '127.0.0.1    localhost.localdomain    localhost' >> /etc/hosts
echo '::1    localhost.localdomain    localhost' >> /etc/hosts
echo '127.0.1.1     "$hostname".localdomain     "$hostname"' >> /etc/hosts

## set root password
passwd

## update repositories and install core applications
pacman -Sy openssh linux-headers linux-lts linux-lts-headers wpa_supplicant wireless_tools xclip --noconfirm

# installing the EFI boot manager
## install boot files
bootctl install
## [OPTION] check boot status
bootctl status
## bootloader configuration
echo 'default arch' > /boot/loader/loader.conf
echo 'timeout 3' >> /boot/loader/loader.conf
echo 'console-mode max' >> /boot/loader/loader.conf

## 3.8 Initramfs
# configuring mkinitcpio.conf, which is used to
# create an initial ramdisk environment (initramfs)
# replace HOOKS
sed -i "/^HOOKS/c\HOOKS=(base udev autodetect modconf block keyboard keymap encrypt lvm2 fsck filesystems)" /etc/mkinitcpio.conf
#[TODO] add usr shutdown?

## designate lvmcrypt cryptdevice
#blkid | grep cryptlvm | awk '{print $2}'
#lsblk -paf
#echo
#echo 'enter full cryptlvm partition (/dev/sdXY) '
#read crypt_dev


#boot_part=$(findmnt | grep /boot | awk '{print $2}')

# adding bootloader entries
# a *.conf file for every kernel that is available
# [TODO] UUID
## bleeding edge kernel
echo 'title Arch Linux BLE' > /boot/loader/entries/arch.conf
echo 'linux /vmlinuz-linux' >> /boot/loader/entries/arch.conf
echo 'initrd /initramfs-linux.img' >> /boot/loader/entries/arch.conf
#echo "options cryptdevice="$crypt_dev":cryptlvm crypto=sha512:aes-xts-plain64:512:0: root=/dev/mapper/vg0-lv_root resume=/dev/mapper/vg0-lv_swap" >> /boot/loader/entries/arch.conf
echo "options cryptdevice=`blkid | grep crypto_LUKS | awk '{print $6}' | sed 's/"//g'`:cryptlvm crypto=sha512:aes-xts-plain64:512:0: root=/dev/mapper/vg0-lv_root rw resume=/dev/mapper/vg0-lv_swap" >> /boot/loader/entries/arch.conf

## lts kernel
echo 'title Arch Linux LTS' > /boot/loader/entries/arch-lts.conf
echo 'linux /vmlinuz-linux-lts' >> /boot/loader/entries/arch-lts.conf
echo 'initrd /initramfs-linux-lts.img' >> /boot/loader/entries/arch-lts.conf
#echo "options cryptdevice="$crypt_dev":cryptlvm crypto=sha512:aes-xts-plain64:512:0: root=/dev/mapper/vg0-lv_root resume=/dev/mapper/vg0-lv_swap" >> /boot/loader/entries/arch-lts.conf
echo "options cryptdevice=`blkid | grep crypto_LUKS | awk '{print $6}' | sed 's/"//g'`:cryptlvm crypto=sha512:aes-xts-plain64:512:0: root=/dev/mapper/vg0-lv_root rw resume=/dev/mapper/vg0-lv_swap" >> /boot/loader/entries/arch-lts.conf

# generate initramfs with mkinitcpio
# for linux preset
mkinitcpio -p linux

# for linux-lts preset
mkinitcpio -p linux-lts

## 3.9 Exit chroot
# exit arch-chroot environment and go back to the archiso environment

echo 'exit'

## 4 Reboot

echo 'umount -R /mnt'

echo 'Remove boot medium'

echo 'reboot'


#### #------------------------
#### 
#### additional comments:
#### 
#### mkinitcpio -p linux-lts
#### 
#### #in the fstab options for 'BOOT'; replace 'rw' with 'ro'
#### #when the kernel is updated remount boot partition read/write:
#### 
#### sudo mount -o remount,rw /dev/sdY1 /boot
#### 
#### #read only:
#### sudo mount -o remount,ro /dev/sdY1 /boot
#### 
#### # for linux-lts preset
#### # do this always separate from the linux preset!!
#### # check location of /boot
#### lsblk -af
#### # remount /boot rw
#### sudo mount -o remount,rw /dev/sda1 /boot
#### # configure arch-lts.conf (see above)
#### # generate
#### mkinitcpio -v -p linux-lts
#### 
#### # [OPTION] LUKS 
#### #--------------------
#### vi /
#### boot/loader/entries/
#### arch.conf
#### 'title Arch Linux Encrypted
#### linux /vmlinuz-linux
#### initrd /initramfs-linux.img
#### options cryptdevice=UUID=<UUID>:<mapped-name> root=/dev/mapper/<mapped-name> quiet rw'
#### 
#### # configuring mkinitcpio.conf
#### # create initramfs
#### vi /etc/mkinitcpio.conf
#### HOOKS=(base udev autodetect modconf block keyboard keymap encrypt lvm2 fsck filesystems)
#### 
#### ## [ERROR] on boot:
#### ##--------------------
#### ## reboot with installation medium
#### 
#### cryptsetup open /dev/sdX2 cryptlvm
#### 
#### mount /dev/volgroup0/lv_root /mnt
#### 
#### mkdir /mnt/boot /mnt/home /mnt/usr /mnt/var
#### 
#### mount /dev/sdX1 /mnt/boot
#### mount /dev/volgroup0/lv_home /mnt/home
#### mount /dev/volgroup0/lv_usr /mnt/usr
#### mount /dev/volgroup0/lv_var /mnt/var
#### 
#### swapon /dev/volgroup0/lv_swap
#### 
#### [CHECK]
#### lsblk -af
#### 
#### arch-chroot /mnt
