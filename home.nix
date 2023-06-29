{ config, pkgs, lib, ... }:

{
  home.username = "nhubao";
  home.homeDirectory = "/home/nhubao";
  home.stateVersion = "23.05";
  home.sessionVariables = {
    LOKI_ADDR = "http://loki-gateway.pp-local.prod";
  };
  fonts.fontconfig.enable = true;
  dconf.settings = {
    "org/gnome/shell" = {
      disable-extension-version-validation = true;
    };
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
      window-size = lib.hm.gvariant.mkTuple [1200 800];
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
      window-size = lib.hm.gvariant.mkTuple [1200 800];
    };
  };
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      userName = "bao.truong";
      userEmail = "bao.truong@parcelperform.com";
      aliases = {
        mr = "!sh -c 'git fetch $1 merge-requests/$2/head:mr-$1-$2 && git checkout mr-$1-$2' -";
      };
      extraConfig = {
        core = {
          editor = "nvim";
          pager = "bat";
        };
      };
    };
    bash = {
      enable = true;
    };
    zsh = {
      enable = true;
      autocd = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      enableVteIntegration = true;
      oh-my-zsh = {
        enable = true;
        plugins = ["git" "sudo" "docker" "docker-compose"];
      };
      historySubstringSearch.enable = true;
      completionInit = ''
        autoload -Uz +X compinit && compinit
        autoload -Uz +X bashcompinit && bashcompinit
      '';
      initExtra = ''
        get_scraper_pod() {
          kubectl get pod -n pp-scraper --no-headers | grep Running | grep -m1 'scheduling-trial' | awk '{print $1}'
        }
        reset_scraper_throttle() {
          kubectl -n pp-scraper exec -it "$(get_scraper_pod)" -- python scripts/reset_scraper_throttle.py
        }
        scraper_pod() {
          kubectl -n pp-scraper exec -it "$(get_scraper_pod)" -- su
        }
        source <(kubectl completion zsh)
        ssm() {
          while [[ $# -gt 0 ]]; do
            local key="$1"
            case $key in
              --profile)
              local PROFILE="$2"
              shift 2
              ;;
              --region)
              local REGION="$2"
              shift 2
              ;;
              *)
              echo "Invalid argument: $1" >&2
              return 1
              ;;
            esac
          done

          if [ -z "$PROFILE" ]; then
            local PROFILE="$(aws configure list-profiles | fzf)"
          fi

          if [ -z "$REGION" ]; then
            if [ -n "$AWS_REGION" ]; then
              local REGION="$AWS_REGION"
            else
              local _region="$(aws configure get region --profile $PROFILE)"
              if [ -n "$_region" ]; then
                local REGION="$_region"
              else
                echo "AWS region is not set"
                return 1
              fi
            fi
          fi

          local INSTANCE=$(aws ec2 describe-instances --filter "Name=tag:allow,Values=ssm" --profile "$PROFILE" --region "$REGION" --query 'Reservations[].Instances[].{Name: Tags[?Key==`Name`].Value | [0], InstanceID: InstanceId }' --output text | fzf | awk '{print $1}')

          if [ -z "$INSTANCE" ]; then
            echo "No instance selected"
            return 1
          else
            echo "Connecting to instance: $INSTANCE with profile $PROFILE, region $REGION"
            aws ssm start-session --target "$INSTANCE" --profile "$PROFILE" --region "$REGION"
          fi
        }
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
  };
}