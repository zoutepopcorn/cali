#!/bin/bash

# set font
## download terminus-font
pacman -Sy terminus-font
## install terminus-font
pacman -Ql terminus-font
## set terminus-font
setfont ter-v14n

# modify pacman.conf
## add color
sed -i 's/#Color/Color/' /etc/pacman.conf
## add total download counter
sed -i 's/#TotalDownload/TotalDownload/' /etc/pacman.conf
## add multilib repository
### [TODO] comment out existing lines
echo '################################' >> /etc/pacman.conf
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf

# yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay


