

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  sources = import ./sources.nix;
  lanzaboote = import sources.lanzaboote;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      lanzaboote.nixosModules.lanzaboote
    ];

  # Filesystems
  fileSystems = lib.mkForce {
    "/" = {
      device = "/dev/mapper/ROOT";
      fsType = "btrfs";
      options = ["subvol=@" "noatime" "nodiratime" "defaults" "ssd" "compress-force=zstd"];
    };
    "/home" = {
      device = "/dev/mapper/ROOT";
      fsType = "btrfs";
      options = ["subvol=@home" "noatime" "nodiratime" "defaults" "ssd" "compress-force=zstd"];
    };
    "/boot" = {
      device = "/dev/disk/by-label/EFI";
      fsType = "vfat";
    };
  };

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = ["random.trustcpu=on" "zswap.compressor=lz4" "zswap.zpool=z3fold" "quiet" "loglevel=3" "systemd.unified_cgroup_hierarchy=1" "cryptomgr.notests" "intel_iommu=igfx_off" "kvm-intel.nested=1" "no_timer_check" "noreplace-smp" "page_alloc_shuffle=1" "rcupdate.rcu_expedited=1" "tsc=reliable" "udev.log_level=3"];
  boot.kernelModules = ["v4l2loopback"];
  boot.blacklistedKernelModules = ["iTCO_wdt"];
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 0;
  boot.extraModprobeConfig = ''
options ec_sys write_support=1
options overlay metacopy=off redirect_dir=off
options i915 enable_fbc=1 fastboot=1 modeset=1 enable_gvt=1
options iwlwifi power_save=1
  '';
  boot.initrd.compressor = "zstd";
  boot.initrd.compressorArgs = ["-19" "-T0"];
  boot.initrd.luks.devices."ROOT".device = lib.mkForce "/dev/disk/by-label/CRYPTROOT";

  # Bootloader.
  boot.bootspec.enable = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;

  # Plymouth
  boot.plymouth.enable = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager {
    enable = true;
    dns = "systemd-resolved";
    firewallBackend = "nftables";
    wifi = {
      backend = "iwd";
      powersave = true;
    };
  }
  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Experimental = true;
        KernelExperimental = "330859bc-7506-492d-9370-9a6f0614037f";
      };
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "vi_VN";
    LC_IDENTIFICATION = "vi_VN";
    LC_MEASUREMENT = "vi_VN";
    LC_MONETARY = "vi_VN";
    LC_NAME = "vi_VN";
    LC_NUMERIC = "vi_VN";
    LC_PAPER = "vi_VN";
    LC_TELEPHONE = "vi_VN";
    LC_TIME = "vi_VN";
  };

  # Input method
  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [bamboo];
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    #alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nhubao = {
    isNormalUser = true;
    description = "Nhu Bao Truong";
    initialPassword = "123456";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "realtime" "i2c" "adm" "video" "kvm" "input"];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.joypixels.acceptLicense = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
	  nixos-option docker-compose docker-buildx gnome.gnome-tweaks rar p7zip crun tilix adw-gtk3 lz4 papirus-icon-theme vscode libimobiledevice ripgrep ripgrep-all lsd kubectl awscli2 ssm-session-manager-plugin distrobox genymotion i2c-tools virt-manager sbctl teamviewer expressvpn niv
  ];

  # Nix supported programs
  programs = {
    nix-ld.enable = true;
    git.enable = true;
    zsh.enable = true;
    xwayland.enable = true;
    neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      defaultEditor = true;
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    file-roller.enable = true;
  };

  # Services
  services = {
    usbmuxd.enable = true;  # Usbmuxd
    flatpak.enable = true;  # Flatpak
    tailscale.enable = true;  # Tailscale
    printing.enable = true; # CUPS
    supergfxd.enable = true; # Supergfxd
    ddccontrol.enable = true; # DDC Control
    chrony.enable = true; # Chrony
  };

  # Fonts
  fonts.fonts = with pkgs; [
    joypixels noto-fonts noto-fonts-cjk corefonts liberation_ttf dejavu_fonts open-sans roboto 
    (nerdfonts.override {fonts = ["FiraCode" "Meslo"];})
  ];
  fonts.fontDir.enable = true;

  # GNOME
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos gnome-tour gnome-text-editor gnome-console gnome-connections
  ]) ++ (with pkgs.gnome; [
    cheese gnome-terminal gedit epiphany geary evince gnome-characters totem tali iagno hitori atomix gnome-music gnome-calendar gnome-maps gnome-contacts gnome-software gnome-clocks gnome-calculator gnome-weather yelp simple-scan gnome-logs eog gnome-font-viewer seahorse sushi
  ]);
  services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];
  services.dbus.packages = with pkgs; [gnome2.GConf];

  # Docker
  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
    daemon.settings = {
      default-runtime = "crun";
      runtimes = {
        crun = {
          path = "/run/current-system/sw/bin/crun";
        };
      };
    };
  };

  # Libvirt
  virtualisation.libvirtd.enable = true;

  # Podman
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings = { dns_enabled = true; };
  };

  # Env variables
  environment.variables = {
    EDITOR = "nvim";
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_REMOTE_DBUS = "1";
    MOZ_USE_XINPUT2 = "1";
    DOCKER_BUILDKIT = "1";
    GTK_IM_MODULE = "ibus";
    QT_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
    SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";    
    LIBVA_DRIVER_NAME = "iHD";
  };

  # Nvidia
  services.xserver.videoDrivers = ["nvidia"];
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.modesetting.enable = true;

  # Zram
  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 25;
    priority = 100;
  };

  # Apparmor
  security.apparmor = {
    enable = true;
    packages = with pkgs; [apparmor-pam apparmor-profiles];
  };

  # System-resolved
  networking.nameservers = [ "45.90.28.0#5ef546.dns.nextdns.io" "2a07:a8c0::#5ef546.dns.nextdns.io" "45.90.30.0#5ef546.dns.nextdns.io" "2a07:a8c1::#5ef546.dns.nextdns.io" ];
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [ "45.90.28.0#5ef546.dns.nextdns.io" "2a07:a8c0::#5ef546.dns.nextdns.io" "45.90.30.0#5ef546.dns.nextdns.io" "2a07:a8c1::#5ef546.dns.nextdns.io" ];
    extraConfig = ''
      DNSOverTLS=yes
    '';
  };
  systemd.services.NetworkManager-wait-online.enable = false;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Appstream
  appstream.enable = false;
	
  hardware.ksm.enable = true;
  hardware.i2c.enable = true;

  #hardware.nvidia.prime.sync.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  #networking.firewall = {
  #  enable = true;
  #  allowedTCPPortRanges = []
  #};

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
    
}

