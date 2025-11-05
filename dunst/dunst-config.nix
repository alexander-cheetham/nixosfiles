{ config, pkgs, inputs, ... }:
{

  services.dunst = {
    enable = true;
    settings = {
      global = {
        browser = "${pkgs.xdg-utils}/bin/xdg-open";
        dmenu = "${pkgs.wofi}/bin/wofi -dmenu";
        follow = "mouse";
        format = "<b>%s</b>\\n%b";
        frame_width = 2;
        geometry = "500x5-5+30";
        horizontal_padding = 8;
        icon_position = "off";
        line_height = 0;
        markup = "full";
        padding = 8;
        separator_height = 2;
        transparency = 10;
        word_wrap = true;
      };

      # urgency_low = {
      #   background = "#1d1f21";
      #   foreground = "#4da1af";
      #   frame_color = "#4da1af";
      #   timeout = 10;
      # };

      # urgency_normal = {
      #   background = "#1d1f21";
      #   foreground = "#70a040";
      #   frame_color = "#70a040";
      #   timeout = 15;
      # };

      # urgency_critical = {
      #   background = "#1d1f21";
      #   foreground = "#dd5633";
      #   frame_color = "#dd5633";
      #   timeout = 0;
      # };

      shortcuts = {
        context = "mod4+grave";
        close = "mod4+shift+space";
      };
    };
  };

  # …
}
