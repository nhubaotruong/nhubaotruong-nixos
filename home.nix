{ config, pkgs, lib, ... }:

{
  imports = [
    ./packages.nix
  ];
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
      history = {
        expireDuplicatesFirst = true;
        size = 2147483647;
      };
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
        aws.symbol = "  ";
        buf.symbol = " ";
        c.symbol = " ";
        conda.symbol = " ";
        dart.symbol = " ";
        directory = {
          read_only = " 󰌾";
          truncation_length = 0;
          truncate_to_repo = false;
        };
        docker_context.symbol = " ";
        elixir.symbol = " ";
        elm.symbol = " ";
        fossil_branch.symbol = " ";
        git_branch.symbol = " ";
        golang.symbol = " ";
        guix_shell.symbol = " ";
        haskell.symbol = " ";
        haxe.symbol = "⌘ ";
        hg_branch.symbol = " ";
        hostname.ssh_symbol = " ";
        java.symbol = " ";
        julia.symbol = " ";
        lua.symbol = " ";
        memory_usage.symbol = "󰍛 ";
        meson.symbol = "󰔷 ";
        nim.symbol = "󰆥 ";
        nix_shell.symbol = " ";
        nodejs.symbol = " ";
        package.symbol = "󰏗 ";
        pijul_channel = "🪺 ";
        perl.symbol = " ";
        php.symbol = " ";
        python = {
          symbol = " ";
          style = "blue bold";
        };
        ruby.symbol = " ";
        rust.symbol = " ";
        scala.symbol = " ";
        rlang.symbol = "󰟔 ";
        terraform.symbol = " ";
        swift.symbol = "ﯣ ";
        spack.symbol = "🅢 ";
        os.symbols = {
          Alpaquita = " ";
          Alpine = " ";
          Amazon = " ";
          Android = " ";
          Arch = " ";
          Artix = " ";
          CentOS = " ";
          Debian = " ";
          DragonFly = " ";
          Emscripten = " ";
          EndeavourOS = " ";
          Fedora = " ";
          FreeBSD = " ";
          Garuda = "󰛓 ";
          Gentoo = " ";
          HardenedBSD = "󰞌 ";
          Illumos = "󰈸 ";
          Linux = " ";
          Mabox = " ";
          Macos = " ";
          Manjaro = " ";
          Mariner = " ";
          MidnightBSD = " ";
          Mint = " ";
          NetBSD = " ";
          NixOS = " ";
          OpenBSD = "󰈺 ";
          openSUSE = " ";
          OracleLinux = "󰌷 ";
          Pop = " ";
          Raspbian = " ";
          Redhat = " ";
          RedHatEnterprise = " ";
          Redox = "󰀘 ";
          Solus = "󰠳 ";
          SUSE = " ";
          Ubuntu = " ";
          Unknown = " ";
          Windows = "󰍲 ";
        };
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
  home.file =
    let symlink = config.lib.file.mkOutOfStoreSymlink;
    in
    {
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
      "${config.xdg.configHome}/wireplumber/policy.lua.d/99-bluetooth-policy.lua".text =
        ''
          bluetooth_policy.policy["media-role.use-headset-profile"] = false
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
