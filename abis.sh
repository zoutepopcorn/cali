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
#pacman -Sy terminus-font
## install terminus-font
#pacman -Ql terminus-font
## set terminus-font
#setfont ter-v14n

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
echo 'enter device (/dev/sd.) ?'
read part
gdisk /dev/sd"$part"

# cryptsetup
## dialog
lsblk
echo 'cryptsetup is about to start'
echo 'lvm volumes ROOT, HOME, VAR, USR & SWAP are being created'
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
echo "/dev/sd"$part" has to be at least $total_size GB"
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

## cryptsetup on designated partition
cryptsetup luksFormat --type luks2 /dev/sd"$part"2
cryptsetup open /dev/sd"$part"2 cryptlvm

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
mkfs.vfat -F 32 -n BOOT /dev/sd"$part"1
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
mount /dev/sd"$part"1 /mnt/boot
mount /dev/mapper/vg0-lv_home /mnt/home
mount /dev/mapper/vg0-lv_usr /mnt/usr
mount /dev/mapper/vg0-lv_var /mnt/var
swapon /dev/mapper/vg0-lv_swap


## update mirrorlist
#pacman -S rankmirrors
#cd /etc/pacman.d
#wget -O mirrorlist.all https://www.archlinux.org/mirrorlist/all/
wget -O mirrorlist.nl 'https://www.archlinux.org/mirrorlist/?country=NL&protocol=http&protocol=https&ip_version=4&ip_version=6$use_mirror_status=on'
#cp mirrorlist.nl mirrorlist.rank
sed -i 's/^.//' mirrorlist.nl
#rankmirrors -v -n 10 mirrorlist.rank | grep -w 'Server =' > mirrorlist

## pacstrap
pacstrap -i /mnt base base-devel

# generate fstab
genfstab -U -p /mnt >> /mnt/etc/fstab
## fstab /usr entry with nopass 0
sed -i '/\/usr/s/.$/0/' /mnt/etc/fstab
## fstab /boot mount as ro
sed -i '/\/boot/s/rw,/ro,/' /mnt/etc/fstab
## fstab /usr mount as ro
sed -i '/\/usr/s/rw,/ro,/' /mnt/etc/fstab
##[OPTION] manually check fstab in vi
#vi /mnt/etc/fstab


# write install device to root
# [TODO] # test if this works
#echo "/dev/sd"$part"" > /mnt/inst_dev.txt
# commented out -> Using UUID via blkid in abis2

ls /mnt
echo

echo 'arch-chroot /mnt'
echo 'pacman -Sy git --noconfirm'
echo 'git clone https://github.com/cytopyge/arch_installation'
echo 'sh /arch_installation/abis2.sh'

exit
