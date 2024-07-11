# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib,  ... }:
let 
sunshineOverride = (pkgs.sunshine.override { cudaSupport = true; });
in 
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nixosfiles/stylix/stylix.nix
      ./nixosfiles/nvidia/nvidia.nix
      ./nixosfiles/tuigreet/greetd.nix
      ./nixosfiles/streaming/streaming.nix
      inputs.home-manager.nixosModules.default
    ];

  # Bootloader.
#  virtual box
 boot.loader.systemd-boot.enable = true;
   boot.loader.efi.canTouchEfiVariables = true;
     boot.kernelModules = [ "uinput" ];
  #vmware 
#  boot.loader.grub.enable = true;
 # boot.loader.grub.device = "/dev/sda";
  #boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  nix.settings.experimental-features = ["nix-command" "flakes"];
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  # Set your time zone.
  time.timeZone = "Europe/London";

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
    layout = "gb";
    xkbVariant = "";
  };

  services.tailscale.enable = true;


  
  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };
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
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = with pkgs; [
  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  wget
  hyprlock
  swww  cudaPackages.cudatoolkit
  #utils 
  meson
  wayland-protocols
  wayland-utils
  wl-clipboard
  wlroots

  #nvidia related stuff
  nvfancontrol
  nvidia-vaapi-driver

  discord
  
  gnupg
  libsecret

  #gtks
  gtk2
  gtk3
  gtk4


  #screen shareeride

  pipewire
  wireplumber

  # notification daemon
  dunst
  libnotify

  #screenshot
  hyprshot

  cinnamon.nemo
  #lxappearance
  #gnome.gdm
  
  # networking
  networkmanagerapplet # GUI for networkmanager
  wofi
  # rofi-wayland
  git
  pavucontrol
  vscode
  toybox
  lshw 
  fastfetch
  zip
  unzip
  
  alacritty
  #mission-center
  zenith-nvidia
  fontpreview


  #streaming stuff
  sunshineOverride
  moonlight-qt
  xorg.libXtst
  

];
security.polkit.enable = true;

# systemd = {
#   user.services.polkit-kde-authentication-agent-1 = {
#     description = "polkit-kde-authentication-agent-1";
#     wantedBy = [ "graphical-session.target" ];
#     wants = [ "graphical-session.target" ];
#     after = [ "graphical-session.target" ];
#     serviceConfig = {
#         Type = "simple";
#         ExecStart = "${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1";
#         Restart = "on-failure";
#         RestartSec = 1;
#         TimeoutStopSec = 10;
#       };
#   };
# };
#
# services.getty.autologinUser = "ac";

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


  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
	enable = true;
	alsa.enable = true;
	alsa.support32Bit = true;
	pulse.enable = true;
};
fonts.packages =  with pkgs; [
	# nerdfonts
	# meslo-lgs-nf
	sf-mono-liga-bin
  sf-pro-bin
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

	hardware.opengl = {
		enable=true;
		driSupport = true;
		driSupport32Bit = true;
    extraPackages = with pkgs; [
    vaapiVdpau
    libvdpau-va-gl
  ];
		};
  
	

  qt.enable = true;
  qt.platformTheme="gtk2";
  qt.style = "gtk2";
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
