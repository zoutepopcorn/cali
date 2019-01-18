#!/bin/bash
#
##
###            _ _        _
###   ___ __ _| (_)  _ __(_) ___ ___
###  / __/ _` | | | | '__| |/ __/ _ \
### | (_| (_| | | | | |  | | (_|  __/
###  \___\__,_|_|_| |_|  |_|\___\___|4
###  _ _|_ _ ._    _  _  
### (_\/|_(_)|_)\/(_|(/_ 
###   /      |  /  _|                     
###
### cali_rice
### cytopyge arch linux installation rice
### fourth and final part of a script series
### (c) 2019 by cytopyge
###
##
#

# ricing packages
sudo mount -o remount,rw /usr
## xorg
yay -Sy --ask xorg xorg-xinit #mesa xf86-video-nouveau
## terminal enhancements
yay -S --ask unclutter rxvt-unicode xterm
## tiling window manager
yay -S --ask i3-gaps rofi dunst
## sound
yay -S --ask pulse-audio alsa-utils
## errata
yay -S --ask iw

sudo mount -o remount,ro /usr

#dotfiles
#clone cytopyge dotfiles
git clone https://github.com/cytopyge/dotfiles.git ~/.dot
#sourcing dotfiles
echo 'source ~/.dot/.xinitrc' > ~/.xinitrc
#echo 'source ~/.dot/.zshrc' > ~/.zshrc
echo 'source ~/.dot/.vimrc' > ~/.vimrc
#echo 'source ~/.dot/.tmux.conf' > ~/.tmux.conf
#echo 'source ~/.dot/.yaourtrc' > ~/.yaourtrc


### #ZSH
### sudo pacman -S zsh
### sudo chsh -s /bin/zsh
### #ZSH completions
### sudo pacman -S zsh-completions
### #ZSH syntax highlighting
### git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.config/zsh-syntax-highlighting
### #git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/zsh/plugins/zsh-syntax-highlighting
### #Powerlevel9k theme
### sudo pacman -S zsh-theme-powerlevel9k
### #powerline fonts
### sudo curl -LSso ~/.local/share/fonts/PowerlineSymbols.otf https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
### sudo curl -LSso ~/.config/fontconfig/conf.d/10-powerline-symbols.conf https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
### #mkdir -p ~/.local/share/fonts/
### #mv  PowerlineSymbols.otf ~/.local/share/fonts/
### fc-cache -vf ~/.local/share/fonts/
### #mkdir -p ~/.config/fontconfig/conf.d/
### #mv 10-powerline-symbols.conf ~/.config/fontconfig/conf.d/
### ##base16-shell
### git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
### #vim pathogen
### mkdir -p ~/.vim/autoload ~/.vim/bundle && \
### curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
### ##vim pathogen plugins
### # base16-vim
### git clone https://github.com/chriskempson/base16-vim.git ~/.vim/bundle/base16-vim
### # nerdtree
### git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree
### # nerdtree-git-plugin
### git clone https://github.com/xuyuanp/nerdtree-git-plugin.git ~/.vim/bundle/nerdtree-git-plugin
### # vim-airline
### git clone https://github.com/vim-airline/vim-airline ~/.vim/bundle/vim-airline
### # vim-airline-themes
### git clone https://github.com/vim-airline/vim-airline-themes ~/.vim/bundle/vim-airline-themes
### # vim-fugitive
### git clone https://github.com/tpope/vim-fugitive.git ~/.vim/bundle/vim-fugitive
### # vim-sensible
### git clone https://github.com/tpope/vim-sensible.git ~/.vim/bundle/vim-sensible
### # vim-tmux-navigator
### git clone https://github.com/christoomey/vim-tmux-navigator ~/.vim/bundle/vim-tmux-navigator
