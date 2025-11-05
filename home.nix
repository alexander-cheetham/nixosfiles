{ config, pkgs, inputs, ... }:
{

  # Home Manager needs a bit of information about you and the paths it should
 # manage.
  home.username = "ac";
  home.homeDirectory = "/home/ac";
 
 
  xdg.configFile."hypr/hyprland.conf".source =  ./nixosfiles/hyprland/hyprland.conf;
  xdg.configFile."hypr/hyprlock.conf".source =  ./nixosfiles/hyprland/hyprlock.conf;
  # xdg.configFile."hypr/hyprlock.conf".source =  ./nixosfiles/nvidia/nvidia.conf;
   # TODO NIXIFY ABOVE

  imports = [
    ./nixosfiles/hyprland/waybar.nix
    ./nixosfiles/dunst/dunst-config.nix
    # ./nixosfiles/spicetify/spicetify.nix
    inputs.zen-browser.homeModules.twilight
  ];
  programs = {
    zen-browser = {
    enable = true;
    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      # find more options here: https://mozilla.github.io/policy-templates/
    };
  };
    obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        # obs-backgroundremoval
        obs-pipewire-audio-capture
        ];
    };
    fastfetch = {
      enable = true;
      settings = {
          logo= {
              padding =  {
                  top = 2;
              };
          };
          display = {
              "separator"= " -> ";
          };
    modules = [
        "title"
        "separator"
        {
            type= "os";
            key= " OS";
            keyColor= "red";
            format= "{3}";
        }
        {
            type= "kernel";
            key= "├";
            keyColor= "red";
        }
        {
            type= "packages";
            key= "├󰏖";
            keyColor= "red";
        }
        {
            type= "shell";
            key= "└";
            keyColor= "red";
        }
        "break"

        {
            type= "wm";
            key= " DE/WM";
            keyColor= "blue";
        }
        {
            type= "lm";
            key= "├󰧨";
            keyColor= "blue";
        }
        {
            type= "wmtheme";
            key= "├󰉼";
            keyColor= "blue";
        }
        {
            type= "icons";
            key= "├󰀻";
            keyColor= "blue";
        }
        {
            type= "terminal";
            key= "├";
            keyColor= "blue";
        }
        {
            type= "wallpaper";
            key= "└󰸉";
            keyColor ="blue";
        }

        "break"
        {
            type= "host";
            key= "󰌢 PC";
            keyColor= "green";
        }
        {
            type= "cpu";
            key= "├ ";
            keyColor= "green";
        }
        {
            type= "gpu";
            key =  "├󰾲 ";
            keyColor= "green";
        }
        {
            type= "disk";
            key= "├";
            keyColor= "green";
        }
        {
            type= "memory";
            key= "├󰑭";
            keyColor= "green";
        }
        {
            type= "swap";
            key= "├󰓡";
            keyColor= "green";
        }
        {
            key= "├󰍹 ";
            keyColor= "green";
            type= "display";
            compactType= "original-with-refresh-rate";
        }
        {
            type= "uptime";
            key= "└󰅐";
            keyColor= "green";
        }

        "break"
        {
            type= "sound";
            key= " SOUND";
            keyColor= "cyan";
        }
        {
            type= "player";
            key= "├󰥠";
            keyColor= "cyan";
        }
        {
            type= "media";
            key= "└󰝚";
            keyColor= "cyan";
        }

        "break"
        "colors"
    ];
      };
    };
    git = {
      enable = true;
    };
#    vscode = {
 #     enable = true;
  #    enableUpdateCheck = false;
   # };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    alacritty = {
      enable = true;
      # use a color scheme from the overlay
      settings = {};
    };
    zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
      plugins = [
                    {
                        name = "powerlevel10k";
                        src = pkgs.zsh-powerlevel10k;
                        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
                    }
                  {
                    name = "z";
                    src = pkgs.zsh-z;
                  }
                  {
                      name = "powerlevel10k-config";
                        src =  ./nixosfiles/p10k-config;
                        file = "p10k.zsh";
                    }
                    
                ];
        shellAliases = {
            ll = "ls -l";
            update = "sudo nixos-rebuild switch";
          };


        history = {
            size = 10000;
            path = "${config.xdg.dataHome}/zsh/history";
        };

      oh-my-zsh = {
            enable = true;
            plugins = [ "git" "z" ];
            #theme = "powerlevel10k";
        };
    };
  };
  stylix.targets = {
      waybar.enable=true;
      gtk.enable = false;
  };

  gtk = {
    enable = true;
    theme = {
      # /etc/profiles/per-user/ac/themes
      name = "Whitesur GTK Dark";
      package = pkgs.whitesur-gtk-theme.override {
        colorVariants =  ["dark"] ;
        themeVariants = [ "blue"];
        altVariants =  ["normal"] ;
        opacityVariants = ["solid"];
        };
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
  };


  home.stateVersion = "24.05";

  home.packages = with pkgs; 
  
  
  [
    _1password-gui
    # firefox also takes ages to compile
    pinta
    fontpreview
    sunshine
    cava
    cmatrix
    #spotify
    gemini-cli
    # open-webui includes open-cv which makes compiling super slow
    onnxruntime
    clapper
    nurl
    kdePackages.okular
    discord
    texlive.combined.scheme-medium
    graphviz 
    tmux
    warp-terminal
    piper

    codex
    awscli2
    node2nix
    gh
    mongodb-compass

    wireguard-tools

    gparted
];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
      OLLAMA_MAX_LOADED_MODELS = 2;
      OLLAMA_NUM_PARALLEL = 1;
  };
  programs.home-manager.enable = true;
}

