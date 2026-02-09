# ~/nixos-config/nixosfiles/stylix/stylix.nix
#
# Stylix theming configuration
# Provides consistent theming across applications via base16 color schemes
#
# Color reference (base16):
#   base00 - Background
#   base01 - Alternate background
#   base05 - Main text color
#   base04 - Alternate text
#   base08 - Red
#   base09 - Orange
#   base0A - Yellow
#   base0B - Green
#   base0C - Cyan
#   base0D - Blue
#   base0E - Purple
#   base0F - Brown
#
{ pkgs, ... }:
{
  stylix.enable = true;
  stylix.autoEnable = true;
  stylix.homeManagerIntegration.autoImport = true;
  stylix.polarity = "dark";

  stylix.image = ../wallpapers/background2.jpg;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/atelier-cave.yaml";

  # Disable theming for specific targets
  stylix.targets.gnome.enable = false;
  stylix.targets.grub.enable = false;
  stylix.targets.regreet.enable = false;

  # Cursor configuration
  stylix.cursor.package = pkgs.capitaine-cursors;
  stylix.cursor.name = "capitaine-cursors";
  stylix.cursor.size = 20;

  # Terminal opacity
  stylix.opacity.terminal = 0.7;

  # Font configuration
  stylix.fonts = {
    sizes = {
      applications = 12;
      desktop = 16;
      popups = 16;
      terminal = 12;
    };

    serif = {
      package = pkgs.sf-pro-bin;
      name = "SF Pro Serif";
    };

    sansSerif = {
      package = pkgs.sf-pro-bin;
      name = "SF Pro Sans";
    };

    monospace = {
      package = pkgs.sf-mono-liga-bin;
      name = "Liga SFMono Nerd Font";
    };

    emoji = {
      package = pkgs.noto-fonts-color-emoji;
      name = "Noto Color Emoji";
    };
  };
}
