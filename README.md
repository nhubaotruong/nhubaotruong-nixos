# Installation steps:

1. Download Nixos minimal image
2. Format disk according to my preference (use LABEL instead of UUID so I don't need to edit the file every install)
```console
sudo su
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-env -iA dosfstools
cfdisk /dev/nvme0n1
mkfs.fat -F 32 /dev/nvme0n1p1
fatlabel /dev/nvme0n1p1 EFI
cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup config /dev/nvme0n1p2 --label CRYPTROOT
cryptsetup open /dev/nvme0n1p2 ROOT
mkfs.btrfs /dev/mapper/ROOT
mount -t btrfs -o defaults,ssd,noatime,nodiratime,compress-force=zstd /dev/mapper/ROOT /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
umount /mnt
mount -t btrfs -o defaults,ssd,noatime,nodiratime,compress-force=zstd,subvol=@ /dev/mapper/ROOT /mnt
mount -t btrfs -o defaults,ssd,noatime,nodiratime,compress-force=zstd,subvol=@home --mkdir /dev/mapper/ROOT /mnt/home
mount --mkdir /dev/nvme0n1p1 /mnt/boot
```
3. Generate hardware (necessary, but will be overwritten by configuration.nix)
```console
nixos-generate-config --root /mnt
```
4. Install nix
```console
curl -L https://raw.githubusercontent.com/nhubaotruong/nhubaotruong-nixos/main/configuration.nix -o /mnt/etc/nixos/configuration.nix
nixos-install
```
