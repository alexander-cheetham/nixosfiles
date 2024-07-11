{ config, pkgs, lib, inputs, ... }:
let
  spicetify-nix = inputs.spicetify-nix;
  spicePkgs = spicetify-nix.packages.${pkgs.system}.default;
in
{
  # allow spotify to be installed if you don't have unfree enabled already
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "spotify"
  ];

  # import the flake's module for your system
  imports = [ spicetify-nix.homeManagerModule];

  # configure spicetify :)
  programs.spicetify =
    {
      enable = true;
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "macchiato";

      # # color definition for custom color scheme. (rosepine)
      # customColorScheme = {
      #   text = "#${config.lib.stylix.colors.base01}";
      #   subtext = "F0F0F0";
      #   sidebar-text = "e0def4";
      #   main = "#${config.lib.stylix.colors.base00}";
      #   sidebar = "2a2837";
      #   player = "191724";
      #   card = "191724";
      #   shadow = "1f1d2e";
      #   selected-row = "797979";
      #   button = "31748f";
      #   button-active = "31748f";
      #   button-disabled = "555169";
      #   tab-active = "ebbcba";
      #   notification = "1db954";
      #   notification-error = "eb6f92";
      #   misc = "6e6a86";
      # };


      enabledExtensions = with spicePkgs.extensions; [
        fullAppDisplay
        shuffle # shuffle+ (special characters are sanitized out of ext names)
        hidePodcasts
      ];
    };
 }