#!/usr/bin/env bash
readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"
#yayayayay
DRIVE="/dev/sda"
USER="archie"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

usage() {
  usage: $PROGNAME [options] [-u user]
  
  Program installs Arch. Thats it.

  OPTIONS:
     -s --system            set which system to install bios | uefi
                              defaults to bios
     -u --user              set which user should have files installed
                              defaults to current user
     -h --help              show this help
  
  Examples:
     Print the status of the dotfiles install
     $PROGNAME
  EOF
}

cmdline() {
  echo "cmdline"
  for arg
    do
        delim=""
        case "$arg" in
        #translate --gnu-long-options to -g (short options)
            --user) args="${args}-u ";;
           --system-type) args="${args}-s ";;
           #pass through anything else
           *) [[ "${arg:0:1}" == "-" ]] || delim="\""
               args="${args}${delim}${arg}${delim} ";;
        esac
    done
     
    #Reset the positional parameters to the short options
    eval set -- $args
     
    while getopts ":a:us" option >> /dev/null
    do
        case $option in
            u) initial;;
            s) echo "system type";;
            a) echo ${OPTARG[@]};;
            *) echo $OPTARG is an unrecognized option;;
        esac
    done
  # if no args were given print usage
  #is_empty $args \
  #  && usage
}


#echo -en "Does this look correct? (\e[1;32my\e[00m/\e[00;31mn\e[00m) "

#read CORRECT

#if [[ $CORRECT != "y" ]]; then
#  echo -e "\e[00;31mExiting. Won't install\e[00m"
#  exit 1
#fi


#pacman -Sy gptfdisk btrfs-progs vim-minimal

var_check() {
  if [[ $OPTARG -ne 0 ]]; then
    echo $OPTARG[1];
  fi
}

initial() {
 echo "initial"
 pacman --noconfirm -Sy gptfdisk btrfs-progs vim-minimal  
 drive_setup
}

drive_setup() {
  echo "drive_setup"
  fdisk -l $DRIVE
  #(echo o; echo y; echo n; echo; echo; echo +1M; echo ef02; echo n; echo; echo; echo; echo; echo x; echo a; echo 2; echo exit;) | gdisk $DRIVE
}

btrfs_setup() {
  mkfs.btrfs -L ArchHDD /dev/sda2
  mkdir /btrfs
  mount -o defaults,noatime /dev/sda2 /btrfs
  btrfs sub create /btrfs/__active
  mount -o subvol=__active /dev/sda2 /mnt
  mkdir /btrfs/boot /mnt/boot /btrfs/__snapshot
  mount --bind /btrfs/boot /mnt/boot
  mkdir -p /mnt/var/lib/ArchHDD
  chmod -R 0755 /btrfs/__active
}

sys_prep() {
  mkdir /mnt/{proc,dev,sys,var/lib/pacman}
  mount -o bind /dev /mnt/dev
  mount -t sysfs none /mnt/sys
  mount -t proc none /mnt/proc
  pacman --noconfirm -r /mnt -Sy base base-devel syslinux btrfs-progs haveged zsh vim-minimal htop losf strace --ignore grub
  chroot /mnt extlinux -i /boot/syslinux
  cat /mnt/usr/lib/syslinux/bios/gptmbr.bin > /dev/sda
  cp /mnt/usr/lib/syslinux/bios/*.c32 /mnt/boot/syslinux
  sed -i'' 's/sda/sda2/g' /mnt/boot/syslinux.cfg
}

sys_setup() {
  cp /etc/resolv.conf /mnt/etc/resolv.conf
  chroot /mnt haveged -w 1024
  chroot /mnt pacman-key --init
  chroot /mnt pacman-key --populate archlinux
  chroot /mnt pkill haveged
}

pacman_conf() {
  #@TODO: THIS IS HORRIBLE. FIX THIS SOON
  chroot /mnt sed -i'' '92,93 s/#/^/g' /etc/pacman.conf
  chroot /mnt sed -i '94s/^/[archlinuxfr]/' /etc/pacman.conf
  chroot /mnt sed -i '/[archlinuxfr]/a\Server = http://repo.archlinux.fr/$arch' /etc/pacman.conf 
  chroot /mnt sed -i '297s/#/^/g' /etc/pacman.d/mirrorlist
}

user_conf() {
  chroot /mnt useradd $USER
  chroot /mnt gpasswd -a $USER wheel
  chroot /mnt echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  chroot /mnt /home/$USER
  chown $USER:$USER /home/$USER

}

main() {
  echo "main"
  cmdline $ARGS
}
#cmd_line
#initial
main
