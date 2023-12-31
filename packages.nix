{ pkgs, ... }:
{
  environment.systemPackages = (with pkgs; [
    nixos-option
    docker-compose
    docker-buildx
    rar
    p7zip
    crun
    tilix
    adw-gtk3
    lz4
    papirus-icon-theme
    libimobiledevice
    usbmuxd
    ripgrep
    ripgrep-all
    kubectl
    awscli2
    ssm-session-manager-plugin
    distrobox
    genymotion
    i2c-tools
    virt-manager
    sbctl
    teamviewer
    expressvpn
    niv
    starship
    ffmpegthumbnailer
    gnome-epub-thumbnailer
    nufraw-thumbnailer
    jetbrains-toolbox
    breeze-qt5
    appimage-run
    tpm2-tss
    # steam-run
    (gcc.overrideAttrs (oldAttrs: {
      CPPFLAGS = "-march=native";
      CFLAGS = "-march=native";
      CXXFLAGS = "-march=native";
    }))
    python3
    nodejs
    wl-clipboard
    intel-gpu-tools
    rm-improved
    rnix-lsp
    nixfmt
    lm_sensors
    iputils
    usbutils
    pciutils
    powertop
    zip
    unzip
    neofetch
    podman-compose
    ddcutil
    any-nix-shell
  ]) ++ (with pkgs.gnome; [
    gnome-tweaks
    gvfs
    dconf-editor
    nautilus-python
    gnome-screenshot
  ]);
}
