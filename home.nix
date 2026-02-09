# ~/nixos-config/home.nix
#
# Home Manager configuration for user 'ac'
# Manages user-level packages, dotfiles, and program configurations
#
{ config, pkgs, inputs, lib, ... }:
{
  # User information
  home.username = "ac";
  home.homeDirectory = "/home/ac";

  # Hyprland configuration (managed via config files)
  # TODO: Consider migrating to wayland.windowManager.hyprland module
  xdg.configFile."hypr/hyprland.conf".source = ./hyprland/hyprland.conf;
  xdg.configFile."hypr/hyprlock.conf".source = ./hyprland/hyprlock.conf;

  imports = [
    ./hyprland/waybar.nix
    inputs.zen-browser.homeModules.twilight
  ];

  # ============================================================================
  # SERVICES
  # ============================================================================

  services.swaync = {
    enable = true;
    style = ''
      #control-center,
      window#control-center,
      .control-center {
        background-color: rgba(77, 77, 77, 1);
      }
    '';
  };

  # ============================================================================
  # PROGRAMS
  # ============================================================================

  programs = {
    zen-browser = {
      enable = true;
      policies = {
        DisableAppUpdate = true;
        DisableTelemetry = true;
      };
    };

    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
      ];
    };

    fastfetch = {
      enable = true;
      settings = {
        logo = {
          padding = {
            top = 2;
          };
        };
        display = {
          separator = " -> ";
        };
        modules = [
          "title"
          "separator"
          { type = "os"; key = " OS"; keyColor = "red"; format = "{3}"; }
          { type = "kernel"; key = "├"; keyColor = "red"; }
          { type = "packages"; key = "├󰏖"; keyColor = "red"; }
          { type = "shell"; key = "└"; keyColor = "red"; }
          "break"
          { type = "wm"; key = " DE/WM"; keyColor = "blue"; }
          { type = "lm"; key = "├󰧨"; keyColor = "blue"; }
          { type = "wmtheme"; key = "├󰉼"; keyColor = "blue"; }
          { type = "icons"; key = "├󰀻"; keyColor = "blue"; }
          { type = "terminal"; key = "├"; keyColor = "blue"; }
          { type = "wallpaper"; key = "└󰸉"; keyColor = "blue"; }
          "break"
          { type = "host"; key = "󰌢 PC"; keyColor = "green"; }
          { type = "cpu"; key = "├ "; keyColor = "green"; }
          { type = "gpu"; key = "├󰾲 "; keyColor = "green"; }
          { type = "disk"; key = "├"; keyColor = "green"; }
          { type = "memory"; key = "├󰑭"; keyColor = "green"; }
          { type = "swap"; key = "├󰓡"; keyColor = "green"; }
          { type = "display"; key = "├󰍹 "; keyColor = "green"; compactType = "original-with-refresh-rate"; }
          { type = "uptime"; key = "└󰅐"; keyColor = "green"; }
          "break"
          { type = "sound"; key = " SOUND"; keyColor = "cyan"; }
          { type = "player"; key = "├󰥠"; keyColor = "cyan"; }
          { type = "media"; key = "└󰝚"; keyColor = "cyan"; }
          "break"
          "colors"
        ];
      };
    };

    git = {
      enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    alacritty = {
      enable = true;
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
          src = ./p10k-config;
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
      };
    };

    home-manager.enable = true;
  };

  # ============================================================================
  # SYSTEMD SERVICES
  # ============================================================================

  systemd.user.services.waybar = lib.mkIf config.programs.waybar.enable {
    Unit = {
      After = lib.mkAfter [ "swaync.service" "dbus.service" ];
      Wants = lib.mkAfter [ "swaync.service" ];
    };
    Service = {
      Restart = lib.mkForce "on-failure";
    };
  };

  # ============================================================================
  # THEMING
  # ============================================================================

  stylix.targets = {
    waybar.enable = true;
    gtk.enable = false;
    dunst.enable = true;
    swaync.enable = false;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.whitesur-gtk-theme.override {
        colorVariants = [ "dark" ];
        themeVariants = [ "blue" ];
        altVariants = [ "normal" ];
        opacityVariants = [ "solid" ];
      };
      name = "WhiteSur-Dark-solid-blue";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
  };

  # ============================================================================
  # PACKAGES
  # ============================================================================

  home.packages = [
    # Security & Productivity
    pkgs._1password-gui       # Password manager with secure vault
    pkgs.libreoffice-qt       # Office suite (Qt variant for better Wayland support)
    pkgs.file-roller          # Archive manager GUI (zip, tar, etc.)

    # Graphics & Media
    pkgs.pinta                # Simple image editor (Paint.NET alternative)
    pkgs.fontpreview          # Preview fonts in a GUI
    pkgs.clapper              # Modern GTK4 video player
    pkgs.cava                 # Console audio visualizer
    pkgs.cmatrix              # Terminal "Matrix" falling code animation

    # AI & Development Tools
    pkgs.gemini-cli           # Google Gemini AI command-line interface
    pkgs.codex                # OpenAI Codex CLI - AI coding assistant in terminal
    pkgs.onnxruntime          # ML inference runtime for ONNX models

    # Nix Development
    pkgs.nurl                 # Generate Nix fetcher calls from URLs (auto hash prefetch)
    pkgs.node2nix             # Convert npm packages to Nix expressions

    # Cloud & DevOps
    pkgs.awscli2              # Amazon Web Services CLI v2
    pkgs.gh                   # GitHub CLI (gh pr, gh issue, etc.)
    pkgs.wireguard-tools      # WireGuard VPN utilities (wg, wg-quick)

    # Database
    pkgs.mongodb-compass      # MongoDB GUI client

    # Document & Visualization
    pkgs.kdePackages.okular   # PDF and document viewer (KDE)
    pkgs.texlive.combined.scheme-medium # LaTeX distribution for document typesetting
    pkgs.graphviz             # Graph visualization (dot, neato)

    # Communication
    pkgs.discord              # Voice and text chat client

    # Terminal & Shell
    pkgs.tmux                 # Terminal multiplexer (sessions, splits)
    pkgs.warp-terminal        # Modern GPU-accelerated terminal with AI features

    # Hardware & System
    pkgs.piper                # GUI for configuring gaming mice (libratbag)
    pkgs.gparted              # Partition editor GUI
    pkgs.sunshine             # Self-hosted game streaming server (Moonlight host)

    # Browsers
    pkgs.chromium             # Open-source Chromium browser

    # IDE
    pkgs.antigravity-fhs      # Google Antigravity IDE in FHS environment for NixOS
  ];

  # ============================================================================
  # SESSION VARIABLES
  # ============================================================================

  home.sessionVariables = {
    OLLAMA_MAX_LOADED_MODELS = 2;
    OLLAMA_NUM_PARALLEL = 1;
  };

  home.file = { };
  home.stateVersion = "24.05";
}
