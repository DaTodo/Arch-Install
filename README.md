# Arch-Install
Arch Instal

1. HardDrive Setup
  ```
  pacman -Sy gptfdisk btrfs-progs
  
  (echo o; echo y; echo n; echo; echo; echo +1M; echo ef02; echo n; echo; echo; echo; echo; echo x; echo a; echo 2; echo exit;) | gdisk /dev/sda
  ```
2. BTRFS Setup
  ```
  mkfs.btrfs -L ArchHDD /dev/sda2
  
  mkdir /btrfs
  
  mount -o defaults,noatime /dev/sda2 /btrfs
  
  btrfs sub create /btrfs/__active
  
  mount -o subvol=__active /dev/sda2 /mnt
  
  mkdir /btrfs/boot /mnt/boot /btrfs/__snapshot
  
  mount --bind /btrfs/boot /mnt/boot
  
  mkdir -p /mnt/var/lib/ArchHDD
  
  chmod -R 0755 /btrfs/__active
  
  ```
3. System Prep and Installation
  ```
  mkdir /mnt/{proc,dev,sys,var/lib/pacman}
  
  mount -o bind /dev /mnt/dev
  
  mount -t sysfs none /mnt/sys
  
  mount -t proc none /mnt/proc
  
  pacman -r /mnt -Sy base base-devel syslinux btrfs-progs haveged zsh vim --ignore grub
  
  chroot /mnt extlinux -i /boot/syslinux
  
  cat /mnt/usr/lib/syslinux/bios/gptmbr.bin > /dev/sda
  
  cp /mnt/usr/lib/syslinux/bios/*.c32 /mnt/boot/syslinux
  
  sed -i'' 's/sda/sda2/g' /mnt/boot/syslinux.cfg
  
  ```
4. Install Yaourt and mkinitcpio Hook
  ```
  
  cp /etc/resolv.conf /mnt/etc/resolv.conf
  
  chroot /mnt
  
  haveged -w 1024
  
  pacman-key --init
  
  pacman-key --populate archlinux
  
  pkill haveged
  
  ```
  ```
  #####Editting pacman.conf and mirrorlist
  
  sed -i'' '92,93 s/#/^/g' /etc/pacman.conf
  
  sed -i '94s/^/[archlinuxfr]/' /etc/pacman.conf
  
  sed -i '/[archlinuxfr]/a\Server = http://repo.archlinux.fr/$arch' /etc/pacman.conf 
  
  sed -i '297s/#/^/g' /etc/pacman.d/mirrorlist
  
  ```
  
  ```
  
  #####Adding User
  
  useradd korey
  
  (echo Docc1991) | gpasswd -a korey wheel
  
  echo "korey ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  
  mkdir /home/korey
  
  chown korey:korey /home/korey
  
  su korey
  
  ```
  ```
  
  sudo pacman -U kexec-tools-2.0.8-1-x86_64.pkg.tar.xz
  
  yaourt -S mkinitcpio-btrfs
  
  ```
