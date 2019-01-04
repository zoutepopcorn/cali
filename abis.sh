#!/bin/bash
#
##
###        _     _     
###   __ _| |__ (_)___ 
###  / _` | '_ \| / __|
### | (_| | |_) | \__ \
###  \__,_|_.__/|_|___/
###  _ _|_ _ ._    _  _  
### (_\/|_(_)|_)\/(_|(/_ 
###   /      |  /  _|                     
###
### abis
### arch base installation script
### (c) 2019 by cytopyge
###
##
#

# network setup
#
## get network interface
i=$(ip -o -4 route show to default | awk '{print $5}')

## connect to network interface
dhcpcd $i

## handy tools
## lspci -k | grep 'Network controller'
## curl -4 https://ident.me

# set font
#
## download terminus-font
pacman -Sy terminus-font
## install terminus-font
pacman -Ql terminus-font
## set terminus-font
setfont ter-v32n

# set time
#
## network time protocol
timedatectl set-ntp true
## timezone
timedatectl set-timezone Europe/Amsterdam
## verify
timedatectl status

# device partitioning
lsblk
echo 'partition 1 512M ef00 (EFI System)'
echo 'partition 2 rest 8e00 (Linux LVM)'
echo 'enter device (/dev/sd.)?'
read part
gdisk /dev/sd"$part"

# cryptsetup
## dialog
lsblk
echo 'cryptsetup is about to start'
echo 'lvm volumes are being created'
echo '/dev/sd"$part" has to be at least 164 GB'
echo -n 'continue? (Y/n)'
read lvm_continue

if [[ $lvm_continue == "Y" || $lvm_continue == "y" || $lvm_continue = "" ]]; then
        # default option
	# lvm continue positive
	echo 'encrypt partition and create lvm volumes'
else
	# lvm continue negative
	echo 'really exit? (y/N)'
	read lvm_continue_exit_confirm

	if [[ $lvm_continue_exit_confirm == "N" || $lvm_continue_exit_confirm == "n" || $lvm_continue_exit_confirm = "" ]]; then
		# default option
        	# lvm exit confirmation negative
		# [TODO] do nothing
		:
	else
		# lvm exit confirmation positive
		echo 'exiting ...'
		#exit
	fi
fi

## cryptsetup on designated partition
cryptsetup luksFormat --type luks2 /dev/sd"$part"2
cryptsetup open /dev/sd"$part"2 cryptlvm

# creating lvm volumes with lvm
## create physical volume with lvm
pvcreate /dev/mapper/cryptlvm

## create volumegroup vg0 with lvm
vgcreate vg0 /dev/mapper/cryptlvm

## create logical volumes
lvcreate -L 40G vg0 -n lv_root
lvcreate -L 40G vg0 -n lv_home
lvcreate -L 40G vg0 -n lv_usr
lvcreate -L 40G vg0 -n lv_var
lvcreate -L 4G vg0 -n lv_swap

## make filesystems
mkfs.vfat -F 32 -n BOOT /dev/sd"$part"1
mkfs.ext4 -L ROOT /dev/mapper/vg0-lv_root
mkfs.ext4 -L HOME /dev/mapper/vg0-lv_home
mkfs.ext4 -L USR /dev/mapper/vg0-lv_usr
mkfs.ext4 -L VAR /dev/mapper/vg0-lv_var
mkswap -L SWAP /dev/mapper/vg0-lv_swap

## create mountpoints 
mount /dev/vg0/lv_root /mnt
mkdir /mnt/boot
mkdir /mnt/home
mkdir /mnt/usr
mkdir /mnt/var

## mount partitions
mount /dev/sd"$part"1 /mnt/boot
mount /dev/vg0/lv_home /mnt/home
mount /dev/vg0/lv_usr /mnt/usr
mount /dev/vg0/lv_var /mnt/var
swapon /dev/vg0/lv_swap

## update mirrorlist
cd /etc/pacman.d
cp mirrorlist mirrorlist.full
rankmirrors -v -n 10 mirrorlist.full | grep -w 'Server =' > mirrorlist

## pacstrap
pacstrap -i /mnt base base-devel

## generate fstab
genfstab -L -p /mnt >> /mnt/etc/fstab

## arch-chroot
arch-chroot /mnt

## time settings
ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc
sed -i '1ien_US.UTF-8' /etc/locale.gen
locale-gen
sed -i '1iLANG=en_US.UTF-8' /etc/locale.conf

## network configuration
## create the hostname file
echo -n 'Enter hostname?'
read hostname
touch /etc/hostname
echo "$hostname" >> /etc/$hostname
## add matching entries to hosts file
echo '127.0.0.1    localhost.localdomain    localhost' >> /etc/hosts
echo '::1    localhost.localdomain    localhost' >> /etc/hosts
echo '127.0.1.1     "$hostname".localdomain     "$hostname"' >> /etc/hosts

## set root password
passwd

## update repositories and install core applications
pacman -Sy openssh linux-headers linux-lts linux-lts-headers wpa_supplicant wireless_tools xclip

# installing the EFI boot manager
## install boot files
bootctl install
## [OPTION] check boot status
bootctl status
## bootloader configuration
touch /boot/loader/loader.conf
echo 'default arch' >> /boot/loader/loader.conf
echo 'timeout 3' >> /boot/loader/loader.conf
echo 'console-mode max' >> /boot/loader/loader.conf

## 3.8 Initramfs
# configuring mkinitcpio.conf, which is used to
# create an initial ramdisk environment (initramfs)
# replace HOOKS
sed -i "/^HOOKS/c\HOOKS=(base udev autodetect modconf block keyboard keymap encrypt lvm2 fsck filesystems)" /etc/mkinitcpio.conf

# adding bootloader entries
# a *.conf file for every kernel that is available
## bleeding edge kernel
touch /boot/loader/entries/arch.conf
echo 'title Arch Linux BLE' >> /boot/loader/entries/arch.conf
echo 'linux /vmlinuz-linux' >> /boot/loader/entries/arch.conf
echo 'initrd /initramfs-linux.img' >> /boot/loader/entries/arch.conf
echo 'options cryptdevice=[UUID=:lvm]/[/dev/sd"$part"1:lvm] crypto=sha512:aes-xts-plain64:512:0: root=/dev/mapper/volgroup0-lv_root resume=/dev/mapper/volgroup0-lv_swap' >> /boot/loader/entries/arch.conf

## lts kernel
touch /boot/loader/entries/lts.conf
echo 'title Arch Linux LTS' >> /boot/loader/entries/arch.conf
echo 'linux /vmlinuz-linux-lts' >> /boot/loader/entries/arch.conf
echo 'initrd /initramfs-linux-lts.img' >> /boot/loader/entries/arch.conf
echo 'options cryptdevice=[UUID=:lvm]/[/dev/sd"$part"1:lvm] crypto=sha512:aes-xts-plain64:512:0: root=/dev/mapper/volgroup0-lv_root resume=/dev/mapper/volgroup0-lv_swap' >> /boot/loader/entries/arch.conf

# generate initramfs with mkinitcpio
# for linux preset
mkinitcpio -p linux

# for linux-lts preset
mkinitcpio -p linux-lts

## 3.9 Exit chroot
# exit arch-chroot environment and go back to the archiso environment

exit

## 4 Reboot

umount -R /mnt

lsblk
echo 'Remove boot medium'
read -n 1 -s -r -p "Press any key to continue ..."
# remove boot medium

reboot


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
