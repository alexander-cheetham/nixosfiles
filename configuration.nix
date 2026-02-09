# ~/nixos-config/configuration.nix
#
# Main NixOS system configuration
# Imported by flake.nix for the 'desktop' host
#
# Sections:
# - Boot/Hardware
# - Networking
# - Internationalization
# - Services
# - Packages
# - Desktop Environment (Hyprland)
# - Audio (PipeWire)
# - Fonts
# - Portals

{ config, pkgs, inputs, lib, ... }:
let
  # R packages built from source
  mvbutils = pkgs.rPackages.buildRPackage {
    name = "mvbutils";
    src = pkgs.fetchFromGitHub {
      owner = "markbravington";
      repo = "mvbutils";
      rev = "3d278380cf29f47988aa73317107d3ec8c7daa0e";
      hash = "sha256-Pdibb68zfEppSt9BeBNhg8N1GV6eb5uj7cKg+XwDC3E=";
    };
  };

  debug = pkgs.rPackages.buildRPackage {
    name = "debug";
    src = pkgs.fetchFromGitHub {
      owner = "markbravington";
      repo = "debug";
      rev = "1ae9442fd112fc515bcad3d9d5cab575b60fdc32";
      hash = "sha256-U8bYRG9/vaXjMx686xTs38hfMdJDgPetmUqnSWTRSgo=";
    };
    propagatedBuildInputs = [ mvbutils ];
    nativeBuildInputs = [ mvbutils ];
  };

  R-with-my-packages = pkgs.rstudioWrapper.override {
    packages = with pkgs.rPackages; [ ggplot2 mvbutils debug ];
  };

  prismlauncher-wrapped = pkgs.prismlauncher.override {
    additionalPrograms = [ pkgs.ffmpeg ];
    jdks = [
      pkgs.graalvmPackages.graalvm-ce
      pkgs.zulu8
      pkgs.zulu17
      pkgs.zulu
    ];
  };

  # Package categories for organization
  developmentPackages = [
    pkgs.vscode               # Visual Studio Code - extensible code editor
    pkgs.ripgrep              # Fast regex search tool (rg), used by many editors
    pkgs.meson                # Build system for C/C++ projects
    pkgs.gnupg                # GNU Privacy Guard - encryption and signing
    pkgs.libsecret            # Library for storing secrets (passwords, keys)
    pkgs.conda                # Python package and environment manager
  ];

  waylandPackages = [
    pkgs.wayland-protocols    # Wayland protocol extensions
    pkgs.egl-wayland          # EGL External Platform for Wayland
    pkgs.wayland-utils        # Wayland debugging utilities (wayland-info)
    pkgs.wl-clipboard         # Command-line clipboard for Wayland (wl-copy, wl-paste)
    pkgs.wlroots              # Modular Wayland compositor library
    pkgs.hyprlock             # Screen locker for Hyprland
    pkgs.swww                 # Wallpaper daemon for Wayland with fancy transitions
    pkgs.hyprshot             # Screenshot utility for Hyprland
  ];

  desktopPackages = [
    pkgs.alacritty            # GPU-accelerated terminal emulator
    pkgs.wofi                 # Application launcher for Wayland (rofi alternative)
    pkgs.pavucontrol          # PulseAudio/PipeWire volume control GUI
    pkgs.nemo                 # File manager (from Cinnamon desktop)
    pkgs.dunst                # Lightweight notification daemon
    pkgs.libnotify            # Desktop notification library (notify-send)
    pkgs.wlogout              # Logout menu for Wayland compositors
    pkgs.networkmanagerapplet # NetworkManager system tray applet
  ];

  nvidiaPackages = [
    pkgs.cudaPackages.cudatoolkit # NVIDIA CUDA toolkit for GPU computing
    pkgs.libva-utils          # VA-API tools for testing hardware video acceleration
    pkgs.vdpauinfo            # VDPAU info utility for video decode testing
    pkgs.zenith-nvidia        # Terminal system monitor (htop-like) with NVIDIA GPU support
    pkgs.mesa-demos           # OpenGL test programs (glxinfo, glxgears)
  ];

  multimediaPackages = [
    pkgs.spotify              # Spotify music streaming client
    pkgs.moonlight-qt         # Game streaming client for NVIDIA GameStream/Sunshine
    pkgs.whatsapp-electron    # Electron wrapper for WhatsApp Web
  ];

  utilityPackages = [
    pkgs.wget                 # Command-line file downloader
    pkgs.toybox               # Lightweight Unix command-line utilities
    pkgs.lshw                 # Hardware information tool
    pkgs.zip                  # ZIP compression utility
    pkgs.unzip                # ZIP extraction utility
    pkgs.xorg.libXtst         # X11 testing library (needed by some apps)
  ];

  gtkPackages = [
    pkgs.gtk2                 # GTK+ 2 toolkit (legacy apps)
    pkgs.gtk3                 # GTK+ 3 toolkit (most current GTK apps)
    pkgs.gtk4                 # GTK 4 toolkit (newer apps)
    pkgs.libdbusmenu-gtk3     # GTK3 D-Bus menu library (system tray support)
    pkgs.libayatana-appindicator # Application indicator library (tray icons)
  ];

in
{
  imports = [
    ./hardware-configuration.nix
    ./stylix/stylix.nix
    ./nvidia/nvidia.nix
    ./tuigreet/greetd.nix
    ./streaming/streaming.nix
    # Note: home-manager module is imported via flake.nix
  ];

  # ============================================================================
  # BOOT CONFIGURATION
  # ============================================================================

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.kernelModules = [ "uinput" ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    gfxmodeEfi = "2560x1440";
    device = "nodev";
    theme = pkgs.stdenvNoCC.mkDerivation {
      pname = "graphite-grub-theme";
      version = "2k-dark";
      src = pkgs.fetchFromGitHub {
        owner = "vinceliuice";
        repo = "Graphite-gtk-theme";
        rev = "main";
        hash = "sha256-62SOQb3sQCYN1XU6a48RM18EcTUBEh2x0u+S6z8xEfo=";
      };
      nativeBuildInputs = [ pkgs.librsvg ];
      nixosSvg = pkgs.fetchurl {
        url = "https://brand.nixos.org/logos/nixos-logomark-default-flat-recommended.svg";
        sha256 = "sha256-hVId330cHyKdPpVcGG783Z+uC5WMCNp03KIT9htFuuI=";
      };
      installPhase = ''
        set -e
        mkdir -p "$out"
        cp -a other/grub2/common/*.pf2 "$out"/
        cp -a other/grub2/common/*.png "$out"/ 2>/dev/null || true
        cp -a "other/grub2/config/theme-2k.txt" "$out/theme.txt"
        sed -i '/^desktop-image:/d' "$out/theme.txt"
        if grep -q '^desktop-color:' "$out/theme.txt"; then
          sed -i 's|^desktop-color:.*|desktop-color: "#000000"|' "$out/theme.txt"
        else
          printf '\ndesktop-color: "#000000"\n' >> "$out/theme.txt"
        fi
        cp -a "other/grub2/assets/logos/2k" "$out/icons"
        cp -a "other/grub2/assets/assets/2k/"* "$out"/
        mkdir -p "$out/icons"
        rsvg-convert -w 48 -h 48 "$nixosSvg" > "$out/icons/nixos.png"
      '';
    };
  };

  # ============================================================================
  # NIX SETTINGS
  # ============================================================================

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.substituters = [ "https://cuda-maintainers.cachix.org" ];
  nix.settings.extra-trusted-public-keys = [
    "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
  ];
  nix.optimise.automatic = true;
  nix.optimise.dates = [ "03:45" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # ============================================================================
  # NETWORKING
  # ============================================================================

  networking.hostName = "ac";
  networking.networkmanager.enable = true;
  networking.interfaces.enp5s0.wakeOnLan.enable = true;

  # ============================================================================
  # INTERNATIONALIZATION
  # ============================================================================

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };
  console.keyMap = "uk";

  # ============================================================================
  # SERVICES
  # ============================================================================

  services.xserver = {
    enable = true;
    xkb.layout = "gb";
    xkb.variant = "";
  };

  services.ratbagd.enable = true;
  services.blueman.enable = true;
  services.tailscale.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.dbus.enable = true;

  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };
  # Disable ollama auto-start
  systemd.services.ollama.wantedBy = lib.mkForce [ ];

  # ============================================================================
  # USERS
  # ============================================================================

  users.users.ac = {
    isNormalUser = true;
    description = "ac";
    extraGroups = [ "networkmanager" "wheel" "input" ];
    packages = [ ];
  };
  users.defaultUserShell = pkgs.zsh;

  # ============================================================================
  # PACKAGES
  # ============================================================================

  environment.systemPackages =
    developmentPackages ++
    waylandPackages ++
    desktopPackages ++
    nvidiaPackages ++
    multimediaPackages ++
    utilityPackages ++
    gtkPackages ++
    [
      R-with-my-packages
      prismlauncher-wrapped
      pkgs.antigravity-fhs
    ];

  # ============================================================================
  # SECURITY & POLKIT
  # ============================================================================

  security.polkit.enable = true;
  security.rtkit.enable = true;

  systemd.user.services.polkit-kde-authentication-agent-1 = {
    description = "polkit-kde-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # ============================================================================
  # SHELL & PROGRAMS
  # ============================================================================

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  # ============================================================================
  # HOME MANAGER
  # ============================================================================

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users."ac" = import ./home.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  # ============================================================================
  # AUDIO (PipeWire)
  # ============================================================================

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    audio.enable = true;
  };

  # ============================================================================
  # FONTS
  # ============================================================================

  fonts.packages = [
    pkgs.sf-mono-liga-bin
    pkgs.sf-pro-bin
    pkgs.nerd-fonts.fira-code
  ];

  # ============================================================================
  # ENVIRONMENT & PORTALS
  # ============================================================================

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    KITTY_ENABLE_WAYLAND = "1";
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
  };

  # ============================================================================
  # GRAPHICS
  # ============================================================================

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [
      pkgs.nvidia-vaapi-driver
      pkgs.libvdpau-va-gl
      pkgs.libva-vdpau-driver
    ];
  };

  # ============================================================================
  # QT
  # ============================================================================

  qt.enable = true;

  # ============================================================================
  # STATE VERSION
  # ============================================================================

  system.stateVersion = "24.05";
}
