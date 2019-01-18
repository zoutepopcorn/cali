#!/bin/bash
#
##
###            _ _                   _   
###   ___ __ _| (_)  _ __   ___  ___| |_ 
###  / __/ _` | | | | '_ \ / _ \/ __| __|
### | (_| (_| | | | | |_) | (_) \__ \ |_ 
###  \___\__,_|_|_| | .__/ \___/|___/\__|3
###                 |_|                  
###  _ _|_ _ ._    _  _
### (_\/|_(_)|_)\/(_|(/_
###   /      |  /  _|
###
### cali_post
### cytopyge arch linux installation post
### third part of a script series
### (c) 2019 by cytopyge
###
##
#

### download terminus-font
#pacman -Sy terminus-font
### install terminus-font
#pacman -Ql terminus-font
### set terminus-font
#setfont ter-v14n

# modify pacman.conf
## add color
sudo sed -i 's/#Color/Color/' /etc/pacman.conf
## add total download counter
sudo sed -i 's/#TotalDownload/TotalDownload/' /etc/pacman.conf
## add multilib repository
### [TODO] comment out existing lines
sudo echo '################################' >> /etc/pacman.conf
sudo echo '[multilib]' >> /etc/pacman.conf
sudo echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf

# build yay
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
sudo mount -o remount,rw /usr
makepkg -s
makepkg -i 9.0.1-3-x86_64.pkg.tar.xz
sudo mount -o remount,ro /usr
cd
rm -rf /tmp/yay
