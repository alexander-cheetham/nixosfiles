{ pkgs, ...}:
{
  stylix.enable = true;
  stylix.autoEnable = true;
  stylix.polarity = "dark";
  
  stylix.image =  ../wallpapers/mac-background.jpg;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/atelier-cave.yaml";

  # Background color: base00
  #   Alternate background color: base01
  #   Main color: base05
  #   Alternate main color: base04
  #   Red: base08
  #   Orange: base09
  #   Yellow: base0A
  #   Green: base0B
  #   Cyan: base0C
  #   Blue: base0D
  #   Purple: base0E
  #   Brown: base0F
  # stylix.autoEnable = false;
  stylix.targets.gnome.enable = false;
  
  stylix.cursor.package = pkgs.capitaine-cursors;
  stylix.cursor.name = "capitaine-cursors";
  stylix.cursor.size = 10;

  stylix.opacity.terminal = 0.7;
  
  
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
      package = pkgs.noto-fonts-emoji;
      name = "Noto Color Emoji";
    };
  };
  
}
