## Install Arch Linux with ZFS root filesystem, zfs-dkms, ZFSBootMenu, Pacman Auto-snapshots, Secure Boot enabled
![](https://autoize.com/wp-content/uploads/2020/04/linux-bicycle-bookshelf.jpg)

## Configure system BIOS
Disable Secure Boot. ZFS modules can not be loaded if Secure Boot is enabled.

## ZFS automated install script
Before moving on I need to point out that there exists a script that can automate the configuration and install of a ZFS root system.
However as convenient as it sounds the script is limited in flexibility and scope. These limitation cannot be overcome unless one has the time and compacity to edit the script to their liking.
If you want to install a ZFS root system as quickly as possible and don't care about any particulars than take a good look at this github page.
* https://github.com/eoli3n/arch-config


## Get the latest Arch Install media prebuilt with ZFS support
It's entirely possible to build your own Archiso however that takes time and beyond the scope of this guide. For now we'll take a shortcut.
* https://archzfs.leibelt.de/#archiso-with-openzfs-support

## Or use a script to add ZFS support after booting the official Arch linux Install media
By the same developer hosting the prebuilt ZFS supported install media above, the purpose of this script is to skip that step entirely and build the necessary zfs modules within the within the Arch install enviroment.<br>

From the github page, boot on any archiso system, and run:<br>
curl -s https://raw.githubusercontent.com/eoli3n/archiso-zfs/master/init | bash

Before moving on verify you have the zfs modules loaded like so:
<pre>
>lsmod | grep zfs
zfs                  4218880  11
zunicode              339968  1 zfs
zzstd                 552960  1 zfs
zlua                  208896  1 zfs
zavl                   16384  1 zfs
icp                   331776  1 zfs
zcommon               110592  2 zfs,icp
znvpair               118784  2 zfs,zcommon
spl                   122880  6 zfs,icp,zzstd,znvpair,zcommon,zavl
</pre>

## Partitioning your disk(s)
We'll be using the UEFI boot method which requires us to create a EFI partition to launch Linux. Run the following command to identify the hard drive \ partition info:<br>
<pre>
>lsblk
NAME         MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
mmcblk0      179:0    0  29.1G  0 disk
nvme0n1      259:0    0 465.8G  0 disk
</pre>

To make things simple in the above example we'll be using disk "nvme0n1" to hold both the EFI and OS filesystems.<br>
Note: From a security standpoint it is entirely possible to have the EFI (boot) partition on a entirely different disk then the actual OS filesystem. (eg: removable media mmcblk0)<br>

The file with the long string is our target disk (nvme0n1). Save the disk path\UUID into a variable to make things easy:<br>
<pre>
>DISK=/dev/nvme0n1
</pre>

You can use almost any partitioning tool... in this example we'll use gdisk to create the partition scheme.<br>
<pre>
>sgdisk --zap-all $DISK
>sgdisk -n1:1M:+256M -t1:EF00 $DISK
>sgdisk -n2:0:0 -t2:BF00 $DISK
</pre>

Warning: If you're using a Libvirt \ Qemu virtual machine the above commands may fail with an obscure error. If this is the case try using gdisk in interactive mode to manually create the partition scheme. Don't forget the label the partitions correctly: EFI Boot Partition=ef00, Linux Install Partition=bf00
<pre>
>gdisk /dev/vda
</pre>

Now lets verify the partitions are good before moving on:<br>
<pre>
>lsblk
mmcblk0      179:0    0  29.1G  0 disk
nvme0n1      259:0    0 465.8G  0 disk
├─nvme0n1p1  259:1    0   256M  0 part
└─nvme0n1p2  259:2    0 465.5G  0 part
</pre>

## Creating required filesystems and mountpoints
Create the EFI (boot) filesystem on the first partition:
<pre>
>mkfs.vfat -v -F 32 -n EFI /dev/nvme0n1p1
</pre>

Create our zroot pool.<br>
Note: The lowercase and capital o's matter in the command, if you're not using an SSD drive skip the autotrim option, and if you're using a virtual enviroment you can probably omit the compression option as well.
<pre>
>zpool create -f -o ashift=12 \
-o autotrim=on \
-O devices=off \
-O relatime=on \
-O xattr=sa \
-O acltype=posixacl \
-O denodesize=legacy \
-O normalization=formD \
-O compression=lz4 \
-O canmount=off \
-O mountpoint=none \
-R /mnt \
zroot /dev/nvme0n1p2
</pre>

Verify the pool:
<pre>
>zpool status
</pre>

Create filesystem mountpoints and then import \ export test:
<pre>
>zfs create zroot/ROOT
>zfs create -o canmount=noauto -o mountpoint=/ zroot/ROOT/arch
>zfs create -o mountpoint=/home zroot/home
>zpool export zroot
>zpool import -d /dev/nvme0n1p2 -R /mnt zroot -N
</pre>

## Mounting everything together
Mount our mountpoints:
<pre>
>zfs mount zroot/ROOT/arch
>zfs mount -a
>mkdir -p /mnt/{etc/zfs,boot/efi}
>mount /dev/nvme0n1p1 /mnt/boot/efi
</pre>

Check if zfs mounted successfully:
<pre>
>mount | grep mnt
zroot/ROOT/arch on /mnt type zfs (rw,relatime,xattr,posixacl)
zroot/home on /mnt/home type zfs (rw,relatime,xattr,posixacl)
</pre>

Make sure the df output shows all three mountpoints:
<pre>
>df -k
zroot/ROOT/arch... /mnt
zroot/home...      /mnt/home
/dev/nvme0n1p1...  /boot/efi
</pre>

## Configure the ZFS pool
If all is good, move on to set bootfs and create zfs cache file:
<pre>
>zpool set bootfs=zroot/ROOT/arch zroot
>zpool set cachefile=/etc/zfs/zpool.cache zroot
>cp -v /etc/zfs/zpool.cache /mnt/etc/zfs
</pre>

## Install the essential packages for the base Arch linux system
Install packages with pacstrap:
<pre>
>pacman -Syy
>pacstrap /mnt base base-devel linux linux-headers linux-firmware intel-ucode dkms efibootmgr man-db man-pages git nano
</pre>

Generate and configure the filesystem table file.<br>
With nano comment out or delete all lines but the one containing /efi.
<pre>
>genfstab -U -p /mnt >> /mnt/etc/fstab
>nano /mnt/etc/fstab
</pre>

Copy over the dns settings to the new system:
<pre>
>cp -v /etc/resolv.conf /mnt/etc
</pre>

## Chroot into the new system and perform optional tweaks before compilation.
In makepkg.conf on the "CFLAGS" line, remove any -march and -mtune flags, then add -march=native. Scroll down to the line with MAKEFLAGS="-j2" and change that to MAKEFLAGS="-j$(nproc)".Near the bottom of the file look for the file compression options, add "--threads=0" to the COMPRESSZST and COMPRESSXZ commands.<br>
There are further tweaks to be had within this file, please consult the Archlinux wiki below.<br>
* https://wiki.archlinux.org/title/Makepkg

<pre>
>arch-chroot /mnt
>nano /etc/makepkg.conf
</pre>

From the Archlinux wiki Eg:
<pre>
/etc/makepkg.conf
...
CFLAGS="-march=native -O2 -pipe -fno-plt"
...
RUSTFLAGS="-C opt-level=2 -C target-cpu=native"
...
MAKEFLAGS="-j$(nproc)"
...
COMPRESSZST=(zstd -c -z -q --threads=0 -)
COMPRESSXZ=(xz -c -z --threads=0 -)
...
</pre>

## Create a regular User account and give sudo permissions
<pre>
>useradd -m username
>passwd username
>usermod -aG users, sys, adm, log, scanner, power, rfkill, video, storage, optical, lp, audio, wheel
</pre>

Add "%wheel ALL=(ALL) ALL" without quotes using nano:
<pre>
>nano /etc/sudoers.d/username
</pre>

## Su into your new User account and build \ install our pacman helper (Paru).
<pre>
>su username
>sudo pacman -Syy
>git clone https://aur.archlinux.org/paru.git && cd paru
>makepkg -si
</pre>

## Now use Paru to build and install zfs-dkms
<pre>
>cd
>paru -S zfs-dkms
</pre>

## Install additional base packages
This is about the bare minimal packages needed. You can even omit openssh if you don't plan on doing any remote management and terminus-font. Note: You can use dhcpcd in place of networkmanager for a less system resource alternative.
<pre>
>paru -S networkmanager reflector openssh terminus-font
</pre>

In addition, for a more complete Desktop or Laptop experience I recommend install the following packages.<br>
Note: I placed a star next to packages that will require some manual intervention to get working. Look up the package in the Archlinux Wiki for guidance.
<pre>
xdg-user-dirs xdg-utils
bash-completion gpm* tmux terminus-font
inetutils net-tools dnsutils avahi* nss-mdns
firewalld*
tlp* acpi_call acpid*
bluez* bluez-utils
cups*
ntp*
alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack sof-firmware
smartmontools* lm_sensors*
curl wget lsftp rsync
dmidecode lsof htop
fcron
zsh* grml-zsh-config fd fzf*
exfatprogs ntfs-3g dosfstools
neovim
</pre>

## Enable base services
<pre>
>systemctl enable zfs-import-cache
>systemctl enable zfs-import.target
>systemctl enable zfs-mount
>systemctl enable zfs-share
>systemctl enable zfs-zed
>systemctl enable zfs.target
>systemctl enable NetworkManager
>systemctl enable reflector.timer
</pre>

## Generate your hostid file and write it down
<pre>
>sudo zgenhostid $(hostid)
>hostid
</pre>

## Set time zone and generate locales
<pre>
>sudo ln -sf /usr/share/zoneinfo/Pacific/Guam /etc/localtime
>hwclock --systohc
</pre>

Generate your locales, edit /etc/locale.gen and uncomment all locales you need, for example en_US.UTF-8.
<pre>
>nano /etc/locale.gen
>locale-gen
</pre>

## Configure the network
Set your hostname by writing it to /etc/hostname:
<pre>
>echo "hostname" > /etc/hostname
</pre>

Then edit /etc/hosts, where <hostname> is your previously chosen hostname:
<pre>
>echo "127.0.0.1 localhost" >> /etc/hosts
>echo "::1       localhost" >> /etc/hosts
>echo "127.0.0.1 hostname.localdomain hostname" >> /etc/hosts
</pre>

## Configure reflector
Edit the reflector configuration file by adding the correct country and changing "--sort rate".
<pre>
>nano /etc/xdg/reflector.conf
</pre>

## Set default console font
This will make your console look cleaner however you're welcome to customize to you're liking by using another font or changing its size.
<pre>
>sudo nano /etc/vconsole.conf
FONT=ter-128n
</pre>

## Install the EFI bootloader: ZFSBootMenu
<pre>
>mkdir -p /efi/EFI/zbm
>wget https://get.zfsbootmenu.org/latest.EFI -O /efi/EFI/zbm/zfsbootmenu.EFI
>efibootmgr --disk <yourzfsdisk> --part 1 --create --label "ZFSBootMenu" --loader '\EFI\zbm\zfsbootmenu.EFI' --unicode "spl_hostid=$(hostid) zbm.timeout=3 zbm.prefer=zroot zbm.import_policy=hostid" --verbose
</pre>

## Set kernel boot parameters:
<pre>
zfs set org.zfsbootmenu:commandline="noresume init_on_alloc=0 rw spl.spl_hostid=$(hostid)" zroot/ROOT
</pre>

## Edit the initcpio configuration file and regenerate initramfs:
Edit the mkinitcpio configuration file and make sure the HOOKS line are like the following:<br>
"HOOKS=(base udev autodetect modconf block keyboard zfs filesystem)"<br>
<pre>
>nano /mnt/etc/mkinitcpio.conf
>mkinitcpio -P
</pre>

## Assign root password:
<pre>
>passwd

</pre>
## Unmount, reboot and test
<pre>
>umount /mnt/boot/efi
>zfs umount -a
>zpool export zroot
>reboot
</pre>

## Tips and Tricks
To fix the "WARNING: Possible missing firmware" messages whenever regenerating the initramfs:
<pre>
>paru -S mkinitcpio-firmware
</pre>

## System Rescue \ Troubleshooting
If the system won't boot you can remount the zfs pool and EFI boot partition using the install media like before. After troubleshooting, don't forget to unmount it described in the previous step.
<pre>
>lsblk
>zpool import -N -R /mnt zroot
>zfs mount zroot/ROOT/arch
>zfs mount zroot/home
>mount /dev/efibootpartition /mnt/boot/efi
>mount | grep mnt
>arch-chroot /mnt
</pre>

If you're mounting using a different distro eg: Alpine Linux:
<pre>
>zpool import -f zroot
>mount -t zfs zroot/ROOT/alpine /mnt
>mount -t zfs zroot/home /mnt/home
>mount /dev/vda1 /mnt/boot/efi
>mount | grep mnt
>chroot /mnt /usr/bin/env sh
</pre>

Reset the zfs pool and umount
<pre>
>zpool import -f zroot
>zfs umount -a
</pre>





## Possible issues, workarounds, fixes
how to fix missing libcrypto.so.1.1?
* https://unix.stackexchange.com/questions/723616/how-to-fix-missing-libcrypto-so-1-1

/var stays busy at shutdown due to journald #867
* https://github.com/systemd/systemd/issues/867#issuecomment-421655744

Arch Linux, Aur error - FAILED unknown public key
* https://www.garron.me/en/linux/arch-linux-aur-unkdown-public-key.html

zfs-dkms depends on a specific version of the zfs-utils, and zfs-utils depend on a specific version of zfs-dkms, which completely prevents me from updating them
* https://github.com/Morganamilo/paru/issues/707

## References & Software
2022: Arch Linux Root on ZFS from Scratch Tutorial
* https://www.youtube.com/watch?v=CcSjnqreUcQ&list=WL&index=39&t=892s

Guide: Install Arch Linux on an encrypted zpool with ZFSBootMenu as a bootloader
* https://florianesser.ch/posts/20220714-arch-install-zbm

Debian Bullseye installation with ESP on the zpool disk
* https://github.com/zbm-dev/zfsbootmenu/wiki/Debian-Bullseye-installation-with-ESP-on-the-zpool-disk

Setting up Arch + LUKS + BTRFS + systemd-boot + apparmor + Secure Boot + TPM 2.0 - A long, nightmarish journey, now simplified
* https://lemmy.eus/post/2898

Configure systemd ZFS mounts
* https://wiki.archlinux.org/title/Install_Arch_Linux_on_ZFS#Configure_systemd_ZFS_mounts

The Archzfs unofficial user repository offers multiple ways to install the ZFS kernel module.
* https://eoli3n.github.io/2020/05/01/zfs-install.html
* https://github.com/eoli3n/archiso-zfs

Arch Linux pacman hooks
* https://www.youtube.com/watch?v=J8EhTmBX6nc

Paru: Feature packed AUR helper
* https://github.com/morganamilo/paru



## Thank you
Please feel free to leave any helpful comments or suggestions
