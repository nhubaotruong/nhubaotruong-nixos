{ config, pkgs, lib, ... }:

{
  home.username = "nhubao";
  home.homeDirectory = "/home/nhubao";
  home.stateVersion = "23.05";
  home.sessionVariables = {
    LOKI_ADDR = "http://loki-gateway.pp-local.prod";
    NIXOS_OZONE_WL = "1";
  };
  fonts.fontconfig.enable = true;
  dconf.settings = {
    "org/gnome/shell" = { disable-extension-version-validation = true; };
    "org/gtk/gtk4/settings/file-chooser" = {
      clock-format = "12h";
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 230;
      sort-column = "name";
      sort-directories-first = true;
      sort-order = "ascending";
      type-format = "category";
      view-type = "list";
      window-size = lib.hm.gvariant.mkTuple [ 1200 800 ];
    };
    "org/gtk/settings/file-chooser" = {
      clock-format = "12h";
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 230;
      sort-column = "name";
      sort-directories-first = true;
      sort-order = "ascending";
      type-format = "category";
      view-type = "list";
      window-size = lib.hm.gvariant.mkTuple [ 1200 800 ];
    };
    "org/gnome/mutter" = { experimental-features = [ "rt-scheduler" ]; };
    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = false;
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
      speed = 0.2;
    };
  };
  xdg = {
    enable = true;
    desktopEntries = {
      code = {
        categories = [ "Utility" "TextEditor" "Development" "IDE" ];
        comment = "Code Editing. Redefined.";
        exec = "env GTK_USE_PORTAL=1 code --unity-launch %F";
        genericName = "Text Editor";
        icon = "code";
        settings = {
          Keywords = "vscode";
          StartupWMClass = "code-url-handler";
        };
        mimeType = [ "text/plain" "inode/directory" ];
        name = "Visual Studio Code";
        startupNotify = true;
        actions = {
          new-empty-window = {
            exec = "env GTK_USE_PORTAL=1 code --new-window %F";
            icon = "code";
            name = "New Empty Window";
          };
        };
      };
    };
  };
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      userName = "bao.truong";
      userEmail = "bao.truong@parcelperform.com";
      aliases = {
        mr =
          "!sh -c 'git fetch $1 merge-requests/$2/head:mr-$1-$2 && git checkout mr-$1-$2' -";
      };
      extraConfig = {
        core = {
          editor = "nvim";
          pager = "bat";
        };
      };
    };
    bash = { enable = true; };
    zsh = {
      enable = true;
      autocd = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      enableVteIntegration = true;
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "sudo" "docker" "docker-compose" ];
      };
      historySubstringSearch.enable = true;
      completionInit = ''
        autoload -Uz +X compinit && compinit
        autoload -Uz +X bashcompinit && bashcompinit
      '';
      initExtra = ''
        if [ -f ~/.zshrc.old ]; then
          source ~/.zshrc.old
        fi
      '';
    };
    neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      defaultEditor = true;
    };
    gpg.enable = true;
    starship = {
      enable = true;
      settings = {
        aws.symbol = " ";
        conda.symbol = " ";
        dart.symbol = " ";
        directory = {
          read_only = " ";
          truncation_length = 0;
          truncate_to_repo = false;
        };
        docker_context.symbol = " ";
        elixir.symbol = " ";
        elm.symbol = " ";
        git_branch.symbol = " ";
        golang.symbol = " ";
        hg_branch.symbol = " ";
        java.symbol = " ";
        julia.symbol = " ";
        memory_usage.symbol = " ";
        nim.symbol = " ";
        nix_shell.symbol = " ";
        nodejs.symbol = " ";
        package.symbol = " ";
        perl.symbol = " ";
        php.symbol = " ";
        python = {
          symbol = " ";
          style = "blue bold";
        };
        ruby.symbol = " ";
        rust.symbol = " ";
        terraform.symbol = " ";
        swift.symbol = "ﯣ ";
      };
    };
    lsd = {
      enable = true;
      enableAliases = true;
    };
    htop.enable = true;
    btop.enable = true;
    bat.enable = true;
    fzf.enable = true;
    vscode = {
      enable = true;
      package = pkgs.vscode;
    };
    mpv = {
      enable = true;
      config = {
        vo = "gpu";
        hwdec = "vaapi-copy";
        ao = "pipewire,pulse";
      };
    };
  };
  home.shellAliases = {
    "k" = "kubectl";
    "rm" = "rip";
    "grep" = "rga";
    "docker-compose" = "docker-compose --compatibility";
  };
  home.file = let symlink = config.lib.file.mkOutOfStoreSymlink;
  in {
    "${config.home.homeDirectory}/.config/nvim".source =
      symlink "${config.home.homeDirectory}/.backup/nvim";
    "${config.home.homeDirectory}/.aws".source =
      symlink "${config.home.homeDirectory}/.backup/.aws";
    "${config.home.homeDirectory}/.kube".source =
      symlink "${config.home.homeDirectory}/.backup/.kube";
    "${config.home.homeDirectory}/.ssh".source =
      symlink "${config.home.homeDirectory}/.backup/.ssh";
    "${config.home.homeDirectory}/.docker".source =
      symlink "${config.home.homeDirectory}/.backup/.docker";
    "${config.home.homeDirectory}/.zshrc.old".source =
      symlink "${config.home.homeDirectory}/.backup/.zshrc";
    "${config.xdg.configHome}/wireplumber/bluetooth.lua.d/99-bluez-config.lua".text =
      ''
        bluez_monitor.properties = {
        	["bluez5.enable-sbc-xq"] = true,
        	["bluez5.enable-msbc"] = true,
        	["bluez5.enable-hw-volume"] = true,
        	["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '';
    "${config.xdg.configHome}/wireplumber/policy.lua.d/99-bluetooth-policy.lua".text =
      ''
        bluetooth_policy.policy["media-role.use-headset-profile"] = false
      '';
    "${config.xdg.configHome}/pipewire/pipewire.conf.d/99-pipewire.conf".text =
      ''
        context.properties = {
          default.clock.allowed-rates = [ 44100 48000 88200 96000 ]
        }
      '';
    "${config.xdg.configHome}/systemd/user/org.gnome.Shell@x11.service.d/overrides.conf".text =
      ''
        [Service]
        CPUSchedulingPolicy=fifo
        CPUSchedulingResetOnFork=true
      '';
    "${config.xdg.configHome}/systemd/user/org.gnome.Shell@wayland.service.d/overrides.conf".text =
      ''
        [Service]
        CPUSchedulingPolicy=fifo
        CPUSchedulingResetOnFork=true
      '';
  };
}
