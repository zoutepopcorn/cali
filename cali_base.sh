#!/bin/bash
#
##
###            _ _   _                    
###   ___ __ _| (_) | |__   __ _ ___  ___ 
###  / __/ _` | | | | '_ \ / _` / __|/ _ \
### | (_| (_| | | | | |_) | (_| \__ \  __/
###  \___\__,_|_|_| |_.__/ \__,_|___/\___|1
###  _ _|_ _ ._    _  _  
### (_\/|_(_)|_)\/(_|(/_ 
###   /      |  /  _|                     
###
### cali_base
### cytopyge arch linux installation base
### first part of a script series
### (c) 2019 by cytopyge
###
##
#

# clear screen
clear
echo

# network setup
## get network interface
i=$(ip -o -4 route show to default | awk '{print $5}')
## connect to network interface
dhcpcd $i
echo

# set time
## network time protocol
timedatectl set-ntp true
## timezone
timedatectl set-timezone Europe/Amsterdam
## verify
timedatectl status
echo

# device partitioning
## lsblk for human
lsblk -pf
echo
## create boot partition
## info for human
echo 'boot partition ef00 (EFI System)'
echo 'recommended size at least 256M'
echo
echo 'create new GUID partition table with <o>'
echo 'create new EFI System partition with <n>'
echo 'write changes to device with <w>'
echo 'exit gdisk with <q>'
echo
## request boot device path
echo -n 'enter full path of the boot device (/dev/sdX) '
read boot_dev
echo "partitioning "$boot_dev"..."
echo
gdisk "$boot_dev"

## lsblk for human
lsblk -pf
echo
## create lvm partition
## info for human
echo 'lvm partition 8e00 (Linux LVM)'
echo 'recommended size at least 16G'
echo
echo 'create new GUID partition table with <o>'
echo 'create new Logical Volume Manager (LVM) partition with <n>'
echo 'write changes to device with <w>'
echo 'exit gdisk with <q>'
echo
## request lvm device path
echo -n 'enter full path of the lvm device (/dev/sdY) '
read lvm_part
echo "partitioning "$lvm_part"..."
echo
gdisk "$lvm_part"

# cryptsetup
## dialog
lsblk -pf
echo
echo -n 'enter full path of the BOOT partition (/dev/sdXn) '
read boot_part
echo
echo -n 'enter full path of the LVM partition (/dev/sdYm) '
read lvm_part
echo
echo 'cryptsetup is about to start'
echo 'within the encrypted lvm volumegroup the logical volumes'
echo 'ROOT, HOME, VAR, USR & SWAP are being created'
echo
echo -n 'ROOT partition size (GB)? '
read root_size
echo -n 'HOME partition size (GB)? '
read home_size
echo -n 'VAR partition size (GB)? '
read var_size
echo -n 'USR partition size (GB)? '
read usr_size
echo -n 'SWAP partition size (GB)? '
read swap_size
total_size=$(echo $(( root_size + home_size + var_size + usr_size + 4 )))
echo $total_size
echo "lvm partition "$lvm_part" has to be at least $total_size GB"
echo -n 'continue? (Y/n) '
read lvm_continue

if [[ $lvm_continue == "Y" || $lvm_continue == "y" || $lvm_continue = "" ]]; then
        # default option
	# lvm continue positive
	echo 'encrypt partition and create lvm volumes'
else
	# lvm continue negative
	echo 'really exit? (y/N) '
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

# cryptsetup on designated partition
cryptsetup luksFormat --type luks2 "$lvm_part"
cryptsetup open "$lvm_part" cryptlvm

# creating lvm volumes with lvm
## create physical volume with lvm
pvcreate /dev/mapper/cryptlvm
## create volumegroup vg0 with lvm
vgcreate vg0 /dev/mapper/cryptlvm
## create logical volumes
lvcreate -L "$root_size"G vg0 -n lv_root
lvcreate -L "$home_size"G vg0 -n lv_home
lvcreate -L "$var_size"G vg0 -n lv_usr
lvcreate -L "$usr_size"G vg0 -n lv_var
lvcreate -L "$swap_size"G vg0 -n lv_swap
## make filesystems
mkfs.vfat -F 32 -n BOOT "$boot_part"
mkfs.ext4 -L ROOT /dev/mapper/vg0-lv_root
mkfs.ext4 -L HOME /dev/mapper/vg0-lv_home
mkfs.ext4 -L USR /dev/mapper/vg0-lv_usr
mkfs.ext4 -L VAR /dev/mapper/vg0-lv_var
mkswap -L SWAP /dev/mapper/vg0-lv_swap
## create mountpoints 
mount /dev/mapper/vg0-lv_root /mnt
mkdir /mnt/boot
mkdir /mnt/home
mkdir /mnt/usr
mkdir /mnt/var
## mount partitions
mount "$boot_part" /mnt/boot
mount /dev/mapper/vg0-lv_home /mnt/home
mount /dev/mapper/vg0-lv_usr /mnt/usr
mount /dev/mapper/vg0-lv_var /mnt/var
swapon /dev/mapper/vg0-lv_swap

# update mirrorlist
wget -O mirrorlist_nl 'https://www.archlinux.org/mirrorlist/?country=NL&protocol=http&protocol=https&ip_version=4&ip_version=6$use_mirror_status=on'
sed -i 's/^.//' mirrorlist_nl

# install base & base-devel package group
pacstrap -i /mnt base base-devel

# generate fstab
genfstab -U -p /mnt >> /mnt/etc/fstab

# modify fstab
## fstab /usr entry with nopass 0
sed -i '/\/usr/s/.$/0/' /mnt/etc/fstab
## fstab /boot mount as ro
sed -i '/\/boot/s/rw,/ro,/' /mnt/etc/fstab
## fstab /usr mount as ro
sed -i '/\/usr/s/rw,/ro,/' /mnt/etc/fstab

# preparing /mnt environment
echo
#[TODO] sudo?
arch-chroot /mnt pacman -Sy git --noconfirm
arch-chroot /mnt git clone https://github.com/cytopyge/cali /tmp/cali
echo 'changing root'
echo 'to continue execute manually:'
echo 'sh /tmp/cali/cali_conf.sh'
arch-chroot /mnt
