{ config, pkgs, inputs, ... }:
{

  # Home Manager needs a bit of information about you and the paths it should
 # manage.
  home.username = "ac";
  home.homeDirectory = "/home/ac";
 
 
  xdg.configFile."hypr/hyprland.conf".source =  ./nixosfiles/hyprland/hyprland.conf;
  xdg.configFile."hypr/hyprlock.conf".source =  ./nixosfiles/hyprland/hyprlock.conf;
   # TODO NIXIFY ABOVE

  imports = [
    ./nixosfiles/hyprland/waybar.nix
    ./nixosfiles/dunst/dunst-config.nix
    ./nixosfiles/spicetify/spicetify.nix

  ];
  

  stylix.targets.waybar.enable = true;
  programs.alacritty = {
              enable = true;
              # use a color scheme from the overlay
              settings = {};
            };
  stylix.targets.gtk.enable = false;
  stylix.targets.rofi.enable = false;
  stylix.targets.hyprland.enable = true;
  # nixpkgs.overlays = [

  # ];
  # nixpkgs.overlays = [
  #     (final: prev: {
  #       whitesur-gtk-theme = prev.whitesur-gtk-theme.overrideAttrs (oldAttrs: rec {
  #         postInstall = (prev.postInstall) +''
  #            $out/tweaks.sh -g -c Dark \ 
  #           -b "/home/ac/nixos-config/nixosfiles/wallpapers/mac-background.jpg" \
  #           -f monterey \
  #           & echo HELLLLOOOOO
  #       '';

  #       });
  #   }) 
  #   ];

  gtk = {
    enable = true;
    theme = {
      

      # -g default \
      #        -t blue \
      #        -c Dark \ 
      #       -b "/home/ac/nixos-config/nixosfiles/wallpapers/mac-background.jpg" \
      # /etc/profiles/per-user/ac/themes
      name = "Whitesur GTK Dark";
      package = pkgs.whitesur-gtk-theme.override {
        colorVariants =  ["Dark"] ;
        themeVariants = [ "blue"];
        #nautilusStyle = ["mojave"];
        altVariants =  ["normal"] ;
        opacityVariants = ["solid"];
        };

      
    };

    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };
  };




  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # spotify
    unigine-valley
    _1password-gui
    firefox
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/ac/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
      OLLAMA_MAX_LOADED_MODELS = 4;
      OLLAMA_NUM_PARALLEL = 1;
  };
  
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };


  programs.zsh = {
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

  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

