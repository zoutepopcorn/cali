Arch Linux installation - post base install configuration

useradd -m -g users -s /bin/bash -G wheel cytopyge

passwd cytopyge

visudo
%wheel ALL=(ALL) ALL

exit

login as cytopyge

pacman -Sy yay git vim

git clone https://aur.archlinux.org/package-query.git
cd package-query
makepkg -si
cd ..
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd
rm -rf package-query yay

## configure pacman
vim /etc/pacman.conf

#uncomment [multilib]
#uncomment TotalDownload

#add repository:

[archlinuxfr]
SigLevel = Never
Server = http://repo.archlinux.fr/$arch

## update mirrorlist
# cd to a save place
cd ~/test
# copy current mirrorlist
sudo cp /etc/pacman.d/mirrorlist mirrorlist.bu
# download newest complete mirrorlist
curl -o mirrorlist.all https://www.archlinux.org/mirrorlist/all/
# uncomment first character on all lines in mirrorlist.all
sed -i 's/.//' mirrorlist.all
# create new mirrorlist with top 10 fastest
rankmirrors -n 10 mirrorlist.all | sudo grep -w 'Server =' > mirrorlist
# copy mirrorlist with top 10
sudo cp mirrorlist /etc/pacman.d/mirrorlist

## download and install applications
yay --show -w && yay -Syu yay git vim \
linux-lts linux-lts-headers powerline powerline-fonts terminus-font \
zsh zsh-completions srm openssl openvpn bluez bluez-utils \
iotop htop glances wavemon iftop wireshark-gtk ranger feh mupdf zathura

# configuring z shell (zsh)
# check the current default shell type:
echo $SHELL

#changing the shell from bash to z shell
[cytopyge@parvus ~]$ chsh -l
/bin/sh
/bin/bash
/usr/bin/git-shell
/bin/zsh
/usr/bin/zsh
[cytopyge@parvus ~]$ chsh -s /bin/zsh
Changing shell for cytopyge.
Password:
Shell changed.

restart terminal
... configuration dialog ...
history configuration > save default configuration
completion system (compsys) > 1 & 4
key behavior > bindkey -v
on/off follwing are set > beep off 
