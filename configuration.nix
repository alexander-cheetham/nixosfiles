# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib,  ... }:
{
  imports =
    [ 
      ./hardware-configuration.nix
      ./nixosfiles/stylix/stylix.nix
      ./nixosfiles/nvidia/nvidia.nix
      ./nixosfiles/tuigreet/greetd.nix
      ./nixosfiles/streaming/streaming.nix
      # ./nixosfiles/podman/podman.nix
      inputs.home-manager.nixosModules.default
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "uinput" ];
  boot.loader.grub = {
    enable = true;
    efiSupport = true; 
    # Optional but recommended: match your screen; Graphite ships 1080p/2k/4k variants.
    # e.g. 1920x1080 for typical laptops/monitors:
    gfxmodeEfi = "2560x1440";
    device = "nodev"; 
    theme = pkgs.stdenvNoCC.mkDerivation {
      pname = "graphite-grub-theme";
      version = "2k-dark";
      src = pkgs.fetchFromGitHub {
        owner = "vinceliuice";
        repo  = "Graphite-gtk-theme";
        rev   = "main";  # pin a commit if you want reproducibility
        hash  = "sha256-FDuChavpTyNJ0ElajiSX7eKCW06Gj+JXOAUOJGyUvUM=";
      };
      nativeBuildInputs = [ pkgs.librsvg ];  # rsvg-convert
      nixosSvg = pkgs.fetchurl {
        url = "https://brand.nixos.org/logos/nixos-logomark-default-flat-recommended.svg";
        sha256 = "sha256-hVId330cHyKdPpVcGG783Z+uC5WMCNp03KIT9htFuuI=";
      };
      installPhase = ''
        set -e
        mkdir -p "$out"

        # common files (fonts + shared pngs)
        cp -a other/grub2/common/*.pf2 "$out"/
        cp -a other/grub2/common/*.png "$out"/ 2>/dev/null || true

        # screen-specific config -> theme.txt
        cp -a "other/grub2/config/theme-2k.txt" "$out/theme.txt"

        # Remove any desktop-image line, then ensure a quoted desktop-color is present
        sed -i '/^desktop-image:/d' "$out/theme.txt"
        if grep -q '^desktop-color:' "$out/theme.txt"; then
          sed -i 's|^desktop-color:.*|desktop-color: "#000000"|' "$out/theme.txt"
        else
          printf '\ndesktop-color: "#000000"\n' >> "$out/theme.txt"
        fi

        # icons & UI assets
        cp -a "other/grub2/assets/logos/2k" "$out/icons"
        cp -a "other/grub2/assets/assets/2k/"* "$out"/

        # Convert SVG -> PNG for GRUB (icon)
        mkdir -p "$out/icons"
        rsvg-convert -w 48 -h 48 "$nixosSvg" > "$out/icons/nixos.png"
      '';
    };
  };
  boot.loader.efi.efiSysMountPoint = "/boot";


  # enable flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Enable networking
  networking.hostName = "ac"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.interfaces.enp5s0.wakeOnLan.enable = true;
  # Set your time zone.
  time.timeZone = "Europe/London";

  nix.settings = {
    substituters = [
      "https://cuda-maintainers.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  # Select internationalisation properties.
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

  # Configure keymap in X11
  services.xserver = {
    enable=true;
    xkb.layout = "gb";
    xkb.variant = "";
  };

  services.ratbagd.enable = true;
  services.blueman.enable = true;

  services.tailscale.enable = true;
#  services.vscode-server.enable = true;
  
  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };

# services.open-webui = {
#  package = pkgs.open-webui; # pkgs must be from stable, for example nixos-24.11
#  enable = true;
#  environment = {
#    ANONYMIZED_TELEMETRY = "False";
#    DO_NOT_TRACK = "True";
#    SCARF_NO_ANALYTICS = "True";
#    OLLAMA_API_BASE_URL = "http://127.0.0.1:11434/api";
#    OLLAMA_BASE_URL = "http://127.0.0.1:11434";
#  };
#};
  #disable auto start
  systemd.services.ollama.wantedBy = lib.mkForce [ ];


  # Configure console keymap
  console.keyMap = "uk";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ac = {
    isNormalUser = true;
    description = "ac"; 
    extraGroups = [ "networkmanager" "wheel" "input" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  # nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.cudaSupport=true;


  environment.systemPackages = with pkgs;
  let
  mvbutils = pkgs.rPackages.buildRPackage {
    name = "mvbutils";
    src = fetchFromGitHub {
      owner = "markbravington";
      repo = "mvbutils";
      rev = "3d278380cf29f47988aa73317107d3ec8c7daa0e";
      hash = "sha256-Pdibb68zfEppSt9BeBNhg8N1GV6eb5uj7cKg+XwDC3E=";
    };
  };
  
  debug = pkgs.rPackages.buildRPackage {
    name = "debug";
    src = fetchFromGitHub {
      owner = "markbravington";
      repo = "debug";
      rev = "1ae9442fd112fc515bcad3d9d5cab575b60fdc32";
      hash = "sha256-U8bYRG9/vaXjMx686xTs38hfMdJDgPetmUqnSWTRSgo=";
      
    };
    propagatedBuildInputs = [ mvbutils];
     nativeBuildInputs = [ mvbutils ];
  };
    R-with-my-packages = rstudioWrapper.override{ packages = with rPackages; [ ggplot2 mvbutils debug  ]; };
  in 
  [
    
    R-with-my-packages
    wget
    hyprlock
    swww  
    cudaPackages.cudatoolkit
    #utils 
    meson
    wayland-protocols
    egl-wayland
    wayland-utils
    wl-clipboard
    wlroots
    #nvidia related stuff
    libva-utils
    vdpauinfo
    
    gnupg
    libsecret

    #gtks
    gtk2
    gtk3
    gtk4

    vscode
    #screen shareeride

    # pipewire
    #wireplumber

    # notification daemon
    dunst
    libnotify

    #screenshot
    hyprshot

    nemo
    
    # networking
    networkmanagerapplet # GUI for networkmanager
    wofi
    pavucontrol
    toybox
    lshw 
    zip
    unzip
    spotify
    alacritty
    zenith-nvidia
    moonlight-qt
    xorg.libXtst
    glxinfo 

    conda
    whatsapp-electron

    ripgrep

];
security.polkit.enable = true;

services.gvfs.enable = true;
services.udisks2.enable = true;

systemd = {
  user.services.polkit-kde-authentication-agent-1 = {
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
};

nix.optimise.automatic = true;
nix.optimise.dates = [ "03:45" ];

#services.getty.autologinUser = "ac";

nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 14d";
};

programs.zsh.enable = true;
users.defaultUserShell = pkgs.zsh;

programs.hyprland = {
	enable = true;
  xwayland.enable = true;
  withUWSM = true;
};

nixpkgs.overlays = [
	(self: super: {
	waybar = super.waybar.overrideAttrs (oldAttrs: {
	mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
	});
	})
	(final: prev: {
  sf-mono-liga-bin = prev.stdenvNoCC.mkDerivation rec {
    pname = "sf-mono-liga-bin";
    version = "dev";
    src = inputs.sf-mono-liga-src;
    dontConfigure = true;
    installPhase = '' mkdir -p $out/share/fonts/opentype
		   cp -R $src/*.otf $out/share/fonts/opentype/
	 '';
  };
}) 
(final: prev: {
  sf-pro-bin = prev.stdenvNoCC.mkDerivation rec {
    pname = "sf-pro-bin";
    version = "dev";
    src = inputs.sf-pro-src;
    dontConfigure = true;
    installPhase = '' mkdir -p $out/share/fonts/opentype
		   cp -R $src/*.otf $out/share/fonts/opentype/
	 '';
  };
}) 
];

home-manager = {
	extraSpecialArgs = {inherit inputs;};
	users = {
		"ac" = import ./home.nix;
	};
	
        useGlobalPkgs = true;
        useUserPackages = true;
};


  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    audio.enable = true;
    # systemWide = true;
  };
fonts.packages =  with pkgs; [
	sf-mono-liga-bin
  sf-pro-bin
  nerd-fonts.fira-code
];
  environment.sessionVariables = {
	NIXOS_OZONE_WL = "1";
	KITTY_ENABLE_WAYLAND = "1"; #turn back on for native wayland kitty
	};
  services.dbus.enable = true;
    xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
    extraPortals = [
		  pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
  };

	hardware.graphics= {
		enable=true;
		enable32Bit = true;
    extraPackages = with pkgs; [
    nvidia-vaapi-driver
    libvdpau-va-gl
    vaapiVdpau
  ];
		};
  
	

  qt.enable = true;
  #qt.platformTheme="gtk2";
  #qt.style = "gtk2";

  system.stateVersion = "24.05"; # Did you read the comment?

}
