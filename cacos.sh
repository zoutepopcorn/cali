#!/bin/bash
#
##
###   ___ __ _  ___ ___  ___
###  / __/ _` |/ __/ _ \/ __|
### | (_| (_| | (_| (_) \__ \
###  \___\__,_|\___\___/|___/ 2
###  _ _|_ _ ._    _  _  
### (_\/|_(_)|_)\/(_|(/_ 
###   /      |  /  _|                     
###
### cacos
### cytopyge arch configuration script
### second part of a series
### (c) 2019 by cytopyge
###
##
#

#
##
## run this script only after executing 
## cabis in the new environment
## arch-chroot /mnt
## pacman -Sy git
## git clone https://github.com/cytopyge/arch_installation
## sh arch_installation/cacos.sh
##
#

# time settings
## set time zone
ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
## set hwclock
hwclock --systohc

# locale settings
sed -i "/^#en_US.UTF-8 UTF-8/c\en_US.UTF-8 UTF-8" /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# network configuration
## create the hostname file
echo -n 'Enter hostname? '
read hostname
echo "$hostname" > /etc/$hostname
## add matching entries to hosts file
echo '127.0.0.1    localhost.localdomain    localhost' >> /etc/hosts
echo '::1    localhost.localdomain    localhost' >> /etc/hosts
echo '127.0.1.1     "$hostname".localdomain     "$hostname"' >> /etc/hosts

# set root password
passwd

# update repositories and install core applications
pacman -Sy openssh linux-headers linux-lts linux-lts-headers wpa_supplicant wireless_tools xclip vim --noconfirm

# installing the EFI boot manager
## install boot files
bootctl install
## boot loader configuration
echo 'default arch' > /boot/loader/loader.conf
echo 'timeout 3' >> /boot/loader/loader.conf
echo 'console-mode max' >> /boot/loader/loader.conf

# configure mkinitcpio
## create an initial ramdisk environment (initramfs)
## enable systemd HOOKS
sed -i "/^HOOKS/c\HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt sd-lvm2 filesystems fsck)" /etc/mkinitcpio.conf

# adding boot loader entries
## bleeding edge kernel (BLE)
echo 'title Arch Linux BLE' > /boot/loader/entries/arch.conf
echo 'linux /vmlinuz-linux' >> /boot/loader/entries/arch.conf
echo 'initrd /initramfs-linux.img' >> /boot/loader/entries/arch.conf
echo "options rd.luks.name=UUID=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` rw resume=UUID=`blkid | grep lv_swap | awk '{print $3}' | cut -d '"' -f2`" >> /boot/loader/entries/arch.conf

## long term support kernel (LTS)
echo 'title Arch Linux LTS' > /boot/loader/entries/arch-lts.conf
echo 'linux /vmlinuz-linux-lts' >> /boot/loader/entries/arch-lts.conf
echo 'initrd /initramfs-linux-lts.img' >> /boot/loader/entries/arch-lts.conf
echo "options rd.luks.name=UUID=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` rw resume=UUID=`blkid | grep lv_swap | awk '{print $3}' | cut -d '"' -f2`" >> /boot/loader/entries/arch-lts.conf

# default settings for sd-vconsole
touch /etc/vconsole.conf

# generate initramfs with mkinitcpio
## for linux preset
mkinitcpio -p linux

## for linux-lts preset
mkinitcpio -p linux-lts

# add user
## username
echo 'enter username? '
read username
useradd -m -g wheel $username
## password
passwd $username
## priviledge escalation for wheel group
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# exit arch-chroot environment 
## go back to the archiso environment

echo 'exit'
echo 'umount -R /mnt'
echo 'Remove boot medium'

## reboot
echo 'reboot'
echo 'run capos if preferred'
