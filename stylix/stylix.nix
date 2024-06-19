{ pkgs, ...}:
{
  stylix.enable = true;
  
  stylix.image = pkgs.fetchurl {
        url="https://raw.githubusercontent.com/NixOS/nixos-artwork/master/wallpapers/nix-wallpaper-dracula.png";
        sha256 ="sha256-SykeFJXCzkeaxw06np0QkJCK28e0k30PdY8ZDVcQnh4=";
        };
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/darkmoss.yaml";
  # stylix.autoEnable = false;
  stylix.targets.gnome.enable = false;
  
  stylix.cursor.package = pkgs.capitaine-cursors;
  stylix.cursor.name = "capitaine-cursors";
  stylix.cursor.size = 10;
  
  stylix.fonts = {

     sizes = {
       applications = 12;
       desktop = 16;
       popups = 16;
       terminal = 12;
     };
  
    serif = {
      package = pkgs.sf-mono-liga-bin;
      name = "Liga SFMono Nerd Font";

    };

    sansSerif = {
      package = pkgs.sf-mono-liga-bin;
      name = "Liga SFMono Nerd Font";
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
