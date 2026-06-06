#!/bin/bash

echo "Please enter root partition (example /dev/sda3): "
read ROOT

echo "Please enter Home partition (example /dev/sda3): "
read HOME

echo "Please enter windows bootloader partition (example /dev/sda3):"
read BOOTLOADER


echo "Please enter root password: "
read ROOTPASS

echo "Please enter your username: "
read USER

echo "Please enter your password: "
read PASSWORD

mkfs.ext4 $ROOT
mkfs.ext4 $HOME

# mount target and 50mb partition w10
mount $ROOT /mnt
mount --mkdir $HOME /mnt/home
mount --mkdir $BOOTLOADER /mnt/bootloader_w10

pacstrap -K /mnt base base-devel linux linux-firmware vim

# fstab
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc

echo "ACH" > /etc/hostname
cat <<EOF > /etc/hosts
127.0.0.1       localhost
::1             localhost
127.0.1.1       ACH.localdomain    ACH
EOF

pacman -S git curl fuse3 ntfs-3g mtools dosfstools grub networkmanager linux-headers bluez bluez-utils pulseaudio pulseaudio-bluetooth amd-ucode os-prober
grub-install --target=i386-pc /dev/sda
sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable bluetooth
useradd -mG wheel $USER
usermod -aG sudo $USER
echo "${USER}:${PASSWORD}" | chpasswd
echo "root:${ROOTPASS}" | chpasswd

cd /home/ster
git clone https://github.com/Sterliph/custom_setup_arch.git
