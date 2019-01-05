# arch_installation

Globally Unique Identifiers (GUID) partition table (GPT) and Unified Extensible Firmware Interface (UEFI) system partition with systemd to bootstrap the user space for bleeding edge (BLE) and long term support (LTS) arch linux kernel on separate partition (can be a separate boot device) with fully encrypted logical volume manager (LVM) and separate volumes partitions for root, home, var, usr and swap.

when using the abis script:
after booted arch live iso environment manually install git and clone abis:

pacman -Sy git
git clone https://github.com/cytopyge/arch_installation
sh /arch_installation/abis.sh

and off you go!

Resoures:

Installation guide
https://wiki.archlinux.org/index.php/installation_guide

Partitioning
https://wiki.archlinux.org/index.php/Partitioning

https://wiki.archlinux.org/index.php/EFI_System_Partition


