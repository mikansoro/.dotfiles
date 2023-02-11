# Install

Setup the machine: 

``` shell
lsblk

sudo gdisk
#  > /dev/[device-name]
#  > o
#  > n
#    > *enter*
#    > 1MiB
#    > +1G
#    > ef00
#  > n
#    > *enter*
#    > *enter*
#    > *enter*
#    > 8E00
#  > w

read -p "Hostname: " HOSTNAME
read -p "Disk device: " DISK_DEVICE

sudo cryptsetup luksFormat --type luks2 "/dev/${DISK_DEVICE}p2"
sudo cryptsetup open /dev/[device-name] nixos-enc
sudo pvcreate /dev/mapper/nixos-enc
sudo vgcreate nixos-vg /dev/mapper/nixos-enc
sudo lvcreate -L 8G nixos-vg -n swap
sudo lvcreate -l 100%FREE nixos-vg -n root

sudo mkfs.ext4 /dev/nixos-vg/root
sudo mkswap /dev/nixos-vg/swap
sudo mkfs.vfat -n boot "/dev/${DISK_DEVICE}p1"

sudo mount /dev/nixos-vg/root /mnt
sudo swapon /dev/nixos-vg/swap
sudo mkdir /mnt/boot
sudo mount "/dev/${DISK_DEVICE}p1" /mnt/boot

sudo nixos-generate-config --root /mnt

echo "Disks have been partitioned and initial config has been written. Please update the config and then run the install steps in the install guide."

```

Nixos-install via flake: 

``` shell
sudo nixos-install --root /mnt --flake .#${HOSTNAME}
```
