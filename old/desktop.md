Install Desktop environment*

i3 gaps
----------

yay -Sy  yaourt -Sy xorg xorg-xinit xterm iw alsa-utils mesa \
xf86-video-nouveau i3 unclutter

## xf86-input-synaptics
## default configuration file: /usr/share/X11/xorg.conf.d/70-synaptics.conf
## copy to /etc/X11/xorg.conf.d/ and edit
## man synaptics

##Section "InputClass"
##    Identifier "touchpad"
##    Driver "synaptics"
##    MatchIsTouchpad "on"
##        Option "TapButton1" "1"
##        Option "TapButton2" "3"
##        Option "TapButton3" "2"
##        Option "VertEdgeScroll" "on"
##        Option "VertTwoFingerScroll" "on"
##        Option "HorizEdgeScroll" "on"
##        Option "HorizTwoFingerScroll" "on"
##        Option "CircularScrolling" "on"
##        Option "CircScrollTrigger" "2"
##        Option "EmulateTwoFingerMinZ" "40"
##        Option "EmulateTwoFingerMinW" "8"
##        Option "CoastingSpeed" "0"
##        Option "FingerLow" "30"
##        Option "FingerHigh" "50"
##        Option "MaxTapTime" "125"
##        ...
##EndSection











suckless dwm
----------------
yaourt -Sy xorg xorg-xinit xterm iw alsa-utils mesa xf86-video-nouveau

cd ~/src

git clone https://git.suckless.org/dwm
cd ~/src/dwm
edit config.mk
sudo make clean install

echo 'xrandr --output eDP1 --scale 0.6x0.6' > ~/.xinitrc
echo 'exec dwm' > ~/.xinitrc

git clone https://git.suckless.org/dmenu
cd ~/src/dmenu
edit config.mk
sudo make clean install

git clone https://git.suckless.org/st
cd ~/src/st
edit config.mk
sudo make clean install

git clone https://git.suckless.org/slock
cd ~/src/slock
edit config.mk
sudo make clean install

cd ~/src/dwm
edit config.mk
sudo make clean install

# install fonts
## inconsolata
pacman -Sy ttf-inconsolata
## libertine
pacman -Sy ttf-linux-libertine
# installs to: /usr/share/fonts/TTF
# check if installed
fc-list | grep -i inconsolata
... further steps needed

# backlight
xbacklight -set 75
xbacklight -inc 5
xbacklight -dec 5

# headphones:
yay alsa-utils
alsactl restore

#audio volume:
# set volume with amixer
amixer set Master [0-65536]
# volume up
amixer set Master playback 5000+ unmute
# volume down
amixer set Master playback 5000- unmute
# volume up
amixer set Master playback 5%+ unmute
# volume down
amixer set Master playback 5%- unmute
# toggle mute
amixer set Master playback toggle
# mute
amixer set Master playback mute
# unmute
amixer set Master playback unmute

""
I use xbindkeys with my dedicated volume buttons to control the volume level.

Create the file with gedit (or other text editor): /home/~/.xbindkeys.scm

(xbindkey '("XF86AudioRaiseVolume") "amixer set Master 2dB+ unmute")
(xbindkey '("XF86AudioLowerVolume") "amixer set Master 2dB- unmute")
You need to see what keysym Fn + up-arrow and Fn + down-arrow produce with xev.
You can change it if need be (if they don't currently produce
XF86AudioRaiseVolume and XF86AudioLowerVolume) with /home/~/.xmodmap.
""

# update statusbar with
# time6-video
# Statusbar loop
while true; do
   xsetroot -name "$( date +"%a %d %H:%M" )"
   sleep 1m    # Update time every minute
done &

# conky
(conky | while read LINE; do xsetroot -name "$LINE"; done) &

# touchpad
# identify touchpad device
grep -e "Using input driver libinput" ~/.local/share/xorg/Xorg.0.log
# create inputclass for tp
sudo vim /etc/X11/xorg.conf.d/30-touchpad.conf

section "InputClass"
        Identifier "DLL075B:01 06CB:76AF Touchpad"
        MatchIsTouchpad "on"
        Driver "libinput"
        Option "Tapping" "on"
	Option "ClickMethod" "clickfinger"
	Option "NaturalScrolling" "true"
EndSection


===========================================
below is old

the simple way with:

yaourt -Sy gnome gnome-tweak-tool gnome-terminal-transparency

--------------------------------------------------------------------------------

OR (manually, if specific drivers are needed):
(sorry for the mess, these are just notes ...)

- install XORG display server
- install graphics driver
- install display manager

- install XORG display server
(https://wiki.archlinux.org/index.php/Xorg)

- (dell xps 13 & asus ux501j & asusbak)
yaourt -Sy xf86-input-libinput xorg-server xorg-xinit mesa


        (surface pro 4)
        pacman -Sy xf86-input-libinput xorg-server xorg-xinit

- install graphics driver
#determine graphics driver hardware
lspci
#intel
yaourt -Sy xf86-video-intel lib32-intel-dri lib32-mesa lib32-libgl (dell xps 13, archbak(not confirmed))
(surface pro 4)

pacman -Sy xf86-video-intel mesa-libgl (lib32-mesa-libgl)

>>>>>> yaourt -Sy xf86-input-libinput xorg-server xorg-xinit mesa
>>>>>          xf86-video-intel mesa-libgl 
>>>>>>		gnome gnome-tweak-tool
>>>>>> vbx

          #nvidia (native)
         pacman -Sy nvidia lib32-nvidia-libgl nvidia-utils lib32-nvidia-utils (asus ux501j, archbak(not confirmed))

         #nvidia (opensource nouveau)
         pacman -Sy nouveau ...

- install display manager (login manager)

          (https://wiki.archlinux.org/index.php/Display_manager)

         GNOME
yaourt - Sy gnome gnome-tweak-tool

OR
         pacman -Sy gdm gnome-shell gnome-shell-extensions gnome-control-center gnome-terminal gnome-system-monitor                     gnome-tweak-tool nautilus

          same for surface

GDM
sudo systemctl enable gdm
(created symlink)

or (security through obscurity):
sudo systemctl start gdm

for other video cards try:
AMD     xf86-video-amdgpu
Intel     xf86-video-intel
Nvidia     xf86-video-nouveau
as fallback     xf86-video-vesa

*https://wiki.archlinux.org/index.php/Desktop_environment

#Activate bluetooth
sudo systemctl start bluetooth

---------------------------------------------------------------------------------

