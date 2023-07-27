# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
# let
#   linux_pf_pkg = { fetchurl, buildLinux, ... }@args:
#     buildLinux (args // rec {
#       version = "6.4.0-pf1";
#       modDirVersion = version;

#       src = fetchurl {
#         url = "https://codeberg.org/pf-kernel/linux/archive/v6.4-pf1.tar.gz";
#         sha256 = "sha256-/g5vJReO03gBq0CnxEYiDINBetY605p636TxHek8oP8=";
#       };
#       kernelPatches = [ ];

#       extraMeta.branch = "6.4";
#     } // (args.argsOverride or { }));
#   linux_pf = pkgs.callPackage linux_pf_pkg { };
# in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./packages.nix
    ./overlays.nix
  ];

  # Filesystems
  fileSystems =
    let
      mkRoSymBind = path: {
        device = path;
        fsType = "fuse.bindfs";
        options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
      };
      aggregatedFonts = pkgs.buildEnv {
        name = "system-fonts";
        paths = config.fonts.fonts;
        pathsToLink = [ "/share/fonts" ];
      };
      btrfsOptions = [
        "noatime"
        "nodiratime"
        "defaults"
        "ssd"
        "compress-force=zstd"
        "discard=async"
        "space_cache=v2"
      ];
    in
    lib.mkForce {
      "/" = {
        device = "/dev/mapper/ROOT";
        fsType = "btrfs";
        options = ([ "subvol=@" ]) ++ (btrfsOptions);
      };
      "/home" = {
        device = "/dev/mapper/ROOT";
        fsType = "btrfs";
        options = ([ "subvol=@home" ]) ++ (btrfsOptions);
      };
      "/boot" = {
        device = "/dev/disk/by-label/EFI";
        fsType = "vfat";
      };
      "/usr/share/icons" = mkRoSymBind (config.system.path + "/share/icons");
      "/usr/share/fonts" = mkRoSymBind (aggregatedFonts + "/share/fonts");
    };
  swapDevices = [{ device = "/dev/disk/by-label/SWAP"; }];

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_pf);
  boot.kernelParams = [
    "nowatchdog"
    "random.trustcpu=on"
    "zswap.enabled=1"
    "quiet"
    "cgroup_no_v1=all"
    "systemd.unified_cgroup_hierarchy=1"
    "cryptomgr.notests"
    "intel_iommu=igfx_off"
    "kvm-intel.nested=1"
    "no_timer_check"
    "noreplace-smp"
    "page_alloc_shuffle=1"
    "rcupdate.rcu_expedited=1"
    "tsc=reliable"
    "udev.log_level=3"
  ];
  boot.resumeDevice = "/dev/disk/by-label/SWAP";
  boot.extraModulePackages =
    let
      rts5139 = config.boot.kernelPackages.callPackage ./modules/rts5139.nix { };
    in
    (with config.boot.kernelPackages; [ v4l2loopback x86_energy_perf_policy ])
    ++ ([ rts5139 ]);
  boot.kernelModules = [ "v4l2loopback" "lz4" "z3fold" ];
  boot.blacklistedKernelModules = [ "iTCO_wdt" "nouveau" ];
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 0;
  boot.extraModprobeConfig = ''
    options ec_sys write_support=1
    options overlay metacopy=off redirect_dir=off
    options i915 enable_fbc=1 fastboot=1 modeset=1 enable_gvt=1
    options iwlwifi power_save=1
  '';
  boot.initrd.compressor = "zstd";
  boot.initrd.compressorArgs = [ "-19" "-T0" ];
  boot.initrd.luks.devices."ROOT".device =
    lib.mkForce "/dev/disk/by-label/CRYPTROOT";
  boot.initrd.availableKernelModules = [ "tpm_crb" ];
  boot.initrd.systemd.enable = true;
  # Work around for swap
  systemd.services.zswap-configure = {
    description = "Configure zswap";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      echo lz4 > /sys/module/zswap/parameters/compressor
      echo z3fold > /sys/module/zswap/parameters/zpool
    '';
  };

  # Bootloader.
  boot.bootspec.enable = true;
  boot.loader.systemd-boot.enable = true;
  # boot.lanzaboote = {
  #   enable = true;
  #   pkiBundle = "/etc/secureboot";
  # };
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  hardware.cpu.intel.updateMicrocode = true;

  # Sysctl
  boot.kernel.sysctl = { "vm.max_map_count" = 2147483642; };

  # Plymouth
  boot.plymouth.enable = true;

  networking.hostName = "Kappa-Linux"; # Define your hostname.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    wifi = {
      backend = "iwd";
      powersave = true;
    };
  };
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
  # Hardware acceleration
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    intel-ocl
    intel-media-sdk
    intel-vaapi-driver
  ];

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
    ibus.engines = with pkgs.ibus-engines; [ bamboo ];
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
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.zsh;
  users.users.nhubao = {
    isNormalUser = true;
    description = "Nhu Bao Truong";
    initialPassword = "123456";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "libvirtd"
      "realtime"
      "i2c"
      "adm"
      "video"
      "kvm"
      "input"
      "camera"
    ];
    shell = pkgs.zsh;
    subUidRanges = [{
      startUid = 100000;
      count = 65536;
    }];
    subGidRanges = [{
      startGid = 100000;
      count = 65536;
    }];
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.nhubao = import ./home.nix;
  };
  environment.pathsToLink = [ "/share/zsh" "/share/bash-completion" ];

  # Nix-env programs
  programs = {
    zsh.enable = true;
    nix-ld.enable = true;
    xwayland.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    file-roller.enable = true;
    kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
    gphoto2.enable = true;
    # ccache = {
    #   enable = true;
    #   packageNames = [ "linuxPackages_latest" "linux_pf" "uksmd" ];
    # };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.joypixels.acceptLicense = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget 

  # Services
  services = {
    usbmuxd.enable = true; # Usbmuxd
    flatpak.enable = true; # Flatpak
    tailscale.enable = true; # Tailscale
    printing.enable = true; # CUPS
    supergfxd.enable = true; # Supergfxd
    ddccontrol.enable = true; # DDC Control
    power-profiles-daemon.enable = false; # Power Profiles Daemon
    envfs.enable = true; # Envfs
    fstrim.enable = true; # Fstrim
    localtimed.enable = true; # Localtime symlink to /etc
    thermald.enable = true; # Thermald
    gvfs.enable = true; # Gvfs
    dnsmasq = {
      enable = true;
      settings = {
        server = [ "127.0.0.53" ];
        bind-dynamic = true;
      };
    };
  };

  # Fonts
  fonts.fonts = (with pkgs; [
    joypixels
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    corefonts
    liberation_ttf
    dejavu_fonts
    open-sans
    roboto
    (nerdfonts.override { fonts = [ "FiraCode" "Meslo" ]; })
  ]) ++ (with config.nur.repos; [ rewine.ttf-ms-win10 sagikazarmark.sf-pro ]);
  fonts.fontDir.enable = true;
  fonts.fontconfig = {
    defaultFonts.emoji = [ "JoyPixels" "Noto Color Emoji" ];
    allowBitmaps = false;
  };

  # GNOME
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    gnome-text-editor
    gnome-console
    gnome-connections
    power-profiles-daemon
  ]) ++ (with pkgs.gnome; [
    cheese
    gnome-terminal
    gedit
    epiphany
    geary
    evince
    totem
    tali
    iagno
    hitori
    atomix
    gnome-music
    gnome-maps
    gnome-software
    yelp
    simple-scan
    gnome-logs
    eog
    seahorse
  ]);
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  services.dbus.apparmor = "enabled";
  services.gnome = {
    sushi.enable = true;
    gnome-keyring.enable = true;
    gnome-user-share.enable = true;
    gnome-settings-daemon.enable = true;
    gnome-remote-desktop.enable = true;
    glib-networking.enable = true;
    evolution-data-server.enable = true;
    gnome-online-accounts.enable = true;
    gnome-online-miners.enable = true;
  };
  #systemd.user.services."org.gnome.Shell@wayland".serviceConfig = {
  #  CPUSchedulingPolicy = "fifo";
  #  CPUSchedulingResetOnFork = true;
  #};
  #systemd.user.services."org.gnome.Shell@x11".serviceConfig = {
  #  CPUSchedulingPolicy = "fifo";
  #  CPUSchedulingResetOnFork = true;
  #};

  # Docker
  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
    autoPrune.enable = true;
    daemon.settings = {
      default-runtime = "crun";
      runtimes = { crun = { path = "${pkgs.crun}/bin/crun"; }; };
    };
  };

  # Libvirt
  virtualisation.libvirtd.enable = true;

  # Podman
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings = { dns_enabled = true; };
    autoPrune.enable = true;
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
    ENVFS_RESOLVE_ALWAYS = "1";
    GAMEMODERUNEXEC =
      "env __NV_PRIME_RENDER_OFFLOAD=1 env __GLX_VENDOR_LIBRARY_NAME=nvidia env __VK_LAYER_NV_optimus=NVIDIA_only";
    NIX_BUILD_SHELL = "${pkgs.zsh}/bin/zsh";
  };

  # Nvidia
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.powerManagement.finegrained = true;
  hardware.nvidia.prime.offload = {
    enable = true;
    enableOffloadCmd = true;
  };
  hardware.nvidia.prime = {
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:3:0:0";
  };

  # Zram
  # zramSwap = {
  #   enable = true;
  #   algorithm = "lz4";
  #   memoryPercent = 25;
  #   priority = 100;
  # };

  # Apparmor
  security.apparmor = {
    enable = true;
    # policies = pkgs.apparmor-profiles;
  };

  # System-resolved
  # networking.nameservers = [
  #   "45.90.28.0#5ef546.dns.nextdns.io"
  #   "2a07:a8c0::#5ef546.dns.nextdns.io"
  #   "45.90.30.0#5ef546.dns.nextdns.io"
  #   "2a07:a8c1::#5ef546.dns.nextdns.io"
  # ];
  networking.nameservers = [
    "9.9.9.9#dns.quad9.net"
    "2620:fe::fe#dns.quad9.net"
    "149.112.112.112#dns.quad9.net"
    "2620:fe::9#dns.quad9.net"
  ];
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [
      "9.9.9.9#dns.quad9.net"
      "2620:fe::fe#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
      "2620:fe::9#dns.quad9.net"
    ];
    extraConfig = ''
      DNSOverTLS=opportunistic
      MulticastDNS=yes
    '';
  };
  systemd.services.NetworkManager-wait-online.enable = false;

  # TLP
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      SCHED_POWERSAVE_ON_AC = 1;
      SCHED_POWERSAVE_ON_BAT = 1;
      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      AHCI_RUNTIME_PM_ON_AC = "auto";
      AHCI_RUNTIME_PM_ON_BAT = "auto";
      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";
    };
  };

  # Powertop
  powerManagement.powertop.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  #services.openssh.enable = true;

  # Appstream
  appstream.enable = false;

  hardware.ksm.enable = true;
  hardware.i2c.enable = true;

  # Qt
  qt.platformTheme = "gnome";

  # Tpm2
  security.tpm2.enable = true;

  # Firewall
  networking.firewall = {
    enable = true;
    extraCommands = ''
      iptables -F FORWARD
      iptables -P FORWARD ACCEPT
    '';
    trustedInterfaces = [ "docker0" ];
    # allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # Garbage collect
  nix.gc = {
    automatic = true;
    dates = "daily";
  };

  # Optimize store
  nix.settings.auto-optimise-store = true;

  # Realtime-priviliges
  users.groups = { realtime = { }; };
  security.pam.loginLimits = [
    {
      domain = "@realtime";
      type = "-";
      item = "rtprio";
      value = "98";
    }
    {
      domain = "@realtime";
      type = "-";
      item = "memlock";
      value = "unlimited";
    }
    {
      domain = "@realtime";
      type = "-";
      item = "nice";
      value = "-11";
    }
  ];
  services.udev.extraRules = ''
    # rw access to /dev/cpu_dma_latency to prevent CPUs from going into idle state
    KERNEL=="cpu_dma_latency", GROUP="realtime"
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="wl*", RUN+="${pkgs.iw}/bin/iw dev $name set power_save on"
  '';

  # Experimental
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Flatpak workaround
  system.fsPackages = [ pkgs.bindfs ];

  # Steam udev rules
  hardware.steam-hardware.enable = true;

  # Auto update
  system.autoUpgrade = {
    enable = true;
    dates = "*-*-* 20:00:00";
    flake = "path:/home/nhubao/Documents/nhubaotruong-nixos#Kappa-Linux";
  };

  # Prioritize user process
  systemd = {
    extraConfig = ''
      DefaultTimeoutStopSec=5s
    '';
    user.extraConfig = ''
      DefaultTimeoutStopSec=5s
    '';
  };
  # systemd.services."user@".serviceConfig.Delegate = true;

  # Ccache
  # nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

