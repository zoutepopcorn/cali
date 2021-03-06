Install Arch Linux 'bleeding edge release' kernel and a lts kernel, 
GPT with dm-crypt aes 512 bits plain encryption and 
separate root, boot, home, var and swap partitions.

This guide follows roughly the Arch Linux Installation Beginners Guide, 
with added sources along the way.

!! Free and humble advisory; always use the do, check & act principle,
in other words; always check before act to prevent partial or full system loss.

The recommended installations steps are;

1 Pre-installation
1.0 Prepare installation device
1.1 Set the keyboard layout
1.2 Verify the boot mode
1.3 Connect to the Internet
1.4 Update the system clock
1.5 Partition the disks
1.6 Format the partitions
1.7 Mount the file systems

2 Installation
2.1 Configure mirrorlist
2.2 Install base packages

3 Configure the system
3.1 Fstab
3.2 Chroot
3.3 Time zone
3.4 Locale
3.5 Hostname
3.6 Root password
3.7 Boot loader
3.8 Initramfs
3.9 Exit chroot

4 Reboot

-----------------------------------------------------------------------

1 Pre-installation

01.01 Prepare installation device

# download the latest Arch Linux release
https://www.archlinux.org/download/

# write image to usb device
https://wiki.archlinux.org/index.php/USB_flash_installation_media
#Using_dd
dd if=/path/to/archlinux.iso of=/dev/sdX bs=4M status=progress oflag=sync
## download and install direct to /dev/sdX (!check archlinux version):
curl -L https://mirror.i3d.net/pub/archlinux/iso/2018.04.01/archlinux-2018.04.01-x86_64.iso | sudo dd of=/dev/sdX

# insert usb device and reboot the system
# archiso live environment

1.1 Set the keyboard layout

# default console keymap is US
# configure other keyboard layout
# list available layouts
ls /usr/share/kbd/keymaps/**/*.map.gz


1.2 Verify the boot mode

#verify EFI boot mode
ls /sys/firmware/efi/efivars

# [CHECK] internet connection
ip a

1.3 Connect to the Internet

# connecting to internet with ethernet device
dhcpcd eno1

# connecting to internet with wireless device
#identify device, enter credentials, make connection, aquire ip address

# check available drivers for network controller
lspci -k | grep 'Network controller'

# check available network interfaces
ip link
# activate network interface
ip link set <devname> up

# available SSID's
# list all network interfaces for wireless hardware.
iw dev <devname> scan | grep SSID

#iw dev <devname> info; Show information for this interface.
#connected?
iw dev <devname> link

#save credentials
wpa_passphrase <SSID> <passphrase> > wl_cred.wifi

#run deamon
wpa_supplicant -i <device> -c wl_cred.wifi -B

#aqcuire ip address
dhcpcd <devname>

#show state UP
ip link show <devname>

# [CHECK] ip address
ip a

#check internet connection
ping 8.8.8.8

#check external network address
curl ident.me

1.4 Update the system clock

#update systemclock
timedatectl set-ntp true
timedatectl set-timezone Europe/Amsterdam

# [CHECK] service status
timedatectl status

# [OPTION] download and set console font
# available fonts are in /usr/share/kbd/consolefonts/
## install and configure terminus font
pacman -Sy terminus-font
pacman -Ql terminus-font

# set font temporarily
setfont ter-v32n

# set font persistent
/etc/vconsole.conf

FONT=ter-v32n

1.5 Partition the disks


## [OPTION] LVM on LUKS
##=============================
## https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#LUKS_on_LVM

partition 1: /boot
partition 2: LUKS container with: /root /home /usr /var /swap

gdisk /dev/sdX
partition 1 512M ef00 (EFI System)
partition 2 rest 8e00 (Linux LVM)


## create luks encrypted container
cryptsetup luksFormat --type luks2 /dev/sdX2


## open container
cryptsetup open /dev/sdX2 cryptlvm


## create physical volume
pvcreate /dev/mapper/cryptlvm


## create volume group
vgcreate volgroup0 /dev/mapper/cryptlvm


## create logical volumes on the volume group
lvcreate -L 40G volgroup0 -n lv_root
lvcreate -L 40G volgroup0 -n lv_home
lvcreate -L 40G volgroup0 -n lv_usr
lvcreate -L 40G volgroup0 -n lv_var
lvcreate -L 4G volgroup0 -n lv_swap


## create filesystems
mkfs.vfat -F 32 -n BOOT /dev/sdY1
mkfs.ext4 -L ROOT /dev/mapper/volgroup0-lv_root
mkfs.ext4 -L HOME /dev/mapper/volgroup0-lv_home
mkfs.ext4 -L USR /dev/mapper/volgroup0-lv_usr
mkfs.ext4 -L VAR /dev/mapper/volgroup0-lv_var
mkswap -L SWAP /dev/mapper/volgroup0-lv_swap


## mount filesystem partitions
mount /dev/volgroup0/lv_root /mnt

mkdir /mnt/{boot,home,usr,var}

mount /dev/sdY1 /mnt/boot
mount /dev/volgroup0/lv_home /mnt/home
mount /dev/volgroup0/lv_usr /mnt/usr
mount /dev/volgroup0/lv_var /mnt/var

swapon /dev/volgroup0/lv_swap



2 Installation

2.1 [OPTION] Configure mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.org
curl https://www.archlinux.org/mirrorlist/all/ > ~/mirrorlist.all

# remove comments with vim (of course, what else?) to
# activate all servers for rankmirrors' investigation
vim ~/mirrorlist.all
# keypress sequence in vim:
gg C-v G x :wq

rankmirrors -v -n 10 ~/mirrorlist.all | grep -w 'Server =' > ~/mirrorlist
# ...
sudo mv ~/mirrorlist /etc/pacman.d

2.2 Install the base packages

pacstrap -i /mnt base base-devel




3 Configure the system

>>>>3.9 Boot loader

3.1 Fstab

genfstab -L -p /mnt >> /mnt/etc/fstab

# check if all the partitions are in /etc/fstab and if they are correct
# on addition, this can be useful:
      mount | grep sdY1 >> /mnt/etc/fstab

with separate /usr partition:
/etc/fstab fs_passno 0 on /usr (fsck /usr on boot)

# [OPTION] record fstab entries
cat /etc/fstab >> <install_note>

# exit archiso environment and go to the arch-chroot environment

3.2 Chroot

arch-chroot /mnt

3.3 Time zone

ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime

hwclock --systohc

3.4 Locale

vi /etc/locale.gen
:s/#en_US

locale-gen

vi /etc/locale.conf
LANG=en_US.UTF-8

3.5 Hostname

echo <hostname> > /etc/hostname

vi /etc/hosts
127.0.0.1    localhost.localdomain    localhost
::1    localhost.localdomain    localhost
127.0.1.1     <system_name>.localdomain     <system_name>

3.6 Root password

#set password for root
passwd

# download and install additional packages
pacman -Sy openssh linux-headers linux-lts linux-lts-headers wpa_supplicant wireless_tools vim

3.7 Boot loader

# install boot loader
# creates /boot files
bootctl install

# [CHECK] bootloader settings with:
bootctl status
(! no entry suitable as default)

# configure loader.conf
# for boot (menu) configuration
vi /boot/loader/loader.conf
timeout 3
default arch
editor 1

3.8 Initramfs

# configuring mkinitcpio.conf, which is used to
# create an initial ramdisk environment (initramfs)
vi /etc/mkinitcpio.conf

MODULES=(nvme i915 intel_agp) (XPS9360)
HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt sd-lvm2 filesystems fsck)

# configuring boot loader entries
# a *.conf file for every kernel that is available
vi /boot/loader/entries/arch.conf

title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options rd.luks.uuid=[UUID] rd.luks.name=[UUID]=cryptlvm root=/dev/mapper/volgroup0-lv_root rw resume=dev/mapper/volgroup0-lv_swap

# generate initramfs with mkinitcpio
mkinitcpio -p linux linux-lts

3.9 Exit chroot

# exit arch-chroot environment and go back to the archiso environment

4 Reboot

exit

umount -R /mnt

# remove boot medium

reboot


##===================================
##===================================
##===================================



# [OPTION] plain disk encryption
#================================
# configuring dm-crypt plain64 with lvm
#================================
# [OPTION] removing old dm-crypt volume with lvm:
vgchange -a n volgroup0
cryptsetup plainClose lvm
#(create blank GPT)
gdisk /dev/nvme0n1

# [OPTION]
cryptsetup benchmark

# Configure plain disk encryption
#passphrase for sdX
cryptsetup --hash=sha512 --cipher=aes-xts-plain64 --key-size=512 --offset=0 --verify-passphrase open --type=plain /dev/sdX lvm
# [OR] keyfile on sdZ for sdX
cryptsetup --hash=sha512 --cipher=aes-xts-plain64 --key-size=512 --offset=0 key-file=/dev/sdZ open --type=plain /dev/sdX lvm

# [CHECK]
cryptsetup status lvm

# configure Linux Volume Management (LVM)
pvcreate /dev/mapper/lvm
# [OPTION] ('--dataalignment 1m' If using a SSD without partitioning it first)
vgcreate volgroup0 /dev/mapper/lvm
lvcreate -L 40G volgroup0 -n lv_root
lvcreate -L 40G volgroup0 -n home
lvcreate -L 40G volgroup0 -n lv_var
lvcreate -L 4G volgroup0 -n lv_swap
#(-l 100%FREE)

modprobe dm_mod
vgscan
vgchange -ay

# [CHECK] LVM configuration
lvs

# record LVMconfiguration
lvs >> <install_note>

1.6 Format the partitions

# format system partitions
mkfs.vfat -F 32 -n EFI /dev/sdY1
mkfs.ext4 -L ROOT /dev/volgroup0/lv_root
mkfs.ext4 -L HOME /dev/volgroup0/lv_home
mkfs.ext4 -L VAR /dev/volgroup0/lv_var
mkswap -L SWAP /dev/volgroup0/lv_swap

# [CHECK]
lsblk -af

# [OBSOLETE] label system partitions
fatlabel /dev/sdY1 BOOT
e2label /dev/volgroup0/lv_root ROOT
e2label /dev/volgroup0/lv_home HOME
e2label /dev/volgroup0/lv_var VAR
swaplabel -L SWAP /dev/volgroup0/lv_swap

# [CHECK]
lsblk -af

1.7 Mount the file systems

#mount system partitions
mount /dev/volgroup0/lv_root /mnt

mkdir /mnt/boot
mkdir /mnt/home
mkdir /mnt/var

mount /dev/sdY1 /mnt/boot
mount /dev/volgroup0/lv_home /mnt/home
mount /dev/volgroup0/lv_var /mnt/var

swapon /dev/volgroup0/lv_swap

# [CHECK]
lsblk -af

# [OPTION] record partition & mountpoint configuration
lsblk -af >> <install_note>


#------------------------

additional comments:

mkinitcpio -p linux-lts

#in the fstab options for 'BOOT'; replace 'rw' with 'ro'
#when the kernel is updated remount boot partition read/write:

sudo mount -o remount,rw /dev/sdY1 /boot

#read only:
sudo mount -o remount,ro /dev/sdY1 /boot

# for linux-lts preset
# do this always separate from the linux preset!!
# check location of /boot
lsblk -af
# remount /boot rw
sudo mount -o remount,rw /dev/sda1 /boot
# configure arch-lts.conf (see above)
# generate
mkinitcpio -v -p linux-lts

# [OPTION] LUKS 
#--------------------
vi /
boot/loader/entries/
arch.conf
'title Arch Linux Encrypted
linux /vmlinuz-linux
initrd /initramfs-linux.img
options cryptdevice=UUID=<UUID>:<mapped-name> root=/dev/mapper/<mapped-name> quiet rw'

# configuring mkinitcpio.conf
# create initramfs
vi /etc/mkinitcpio.conf
HOOKS=(base udev autodetect modconf block keyboard keymap encrypt lvm2 fsck filesystems)

## [ERROR] on boot:
##--------------------
## reboot with installation medium

cryptsetup open /dev/sdX2 cryptlvm

mount /dev/volgroup0/lv_root /mnt
mount /dev/sdX1 /mnt/boot
mount /dev/volgroup0/lv_home /mnt/home
mount /dev/volgroup0/lv_usr /mnt/usr
mount /dev/volgroup0/lv_var /mnt/var

swapon /dev/volgroup0/lv_swap

[CHECK]
lsblk -af

arch-chroot /mnt
