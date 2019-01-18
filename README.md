# arch_installation

Globally Unique Identifiers (GUID) partition table (GPT) and Unified Extensible Firmware Interface (UEFI) system partition with systemd boot to bootstrap the user space for bleeding edge (BLE) and long term support (LTS) arch linux kernel on separate partition (can be a separate boot device) with fully encrypted logical volume manager (LVM) and separate volumes partitions for root, home, var, usr and swap.

when using the cali scripts:
after booted arch live iso environment manually install git and clone abis:

pacman -Sy git
git clone https://github.com/cytopyge/cali
sh /cali/cali_base.sh

and off you go!

Resoures:

Installation guide
https://wiki.archlinux.org/index.php/installation_guide

Partitioning
https://wiki.archlinux.org/index.php/Partitioning

https://wiki.archlinux.org/index.php/EFI_System_Partition
