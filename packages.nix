{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nixos-option docker-compose docker-buildx gnome.gnome-tweaks gnome.gvfs gnome.dconf-editor rar p7zip crun tilix adw-gtk3 lz4 papirus-icon-theme libimobiledevice ripgrep ripgrep-all kubectl awscli2 ssm-session-manager-plugin distrobox genymotion i2c-tools virt-manager sbctl teamviewer expressvpn niv starship ffmpegthumbnailer gnome-epub-thumbnailer nufraw-thumbnailer jetbrains-toolbox breeze-qt5 appimage-run tpm2-tss steam-run gcc python3 nodejs wl-clipboard gnome.nautilus-python intel-gpu-tools gnome.gnome-screenshot rm-improved
  ];
}
