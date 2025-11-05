{
  pkgs,
  lib,
  config,
  ...
}:

let
  betterTransition = "all 0.3s cubic-bezier(.55,-0.68,.48,1.682)";
in
with lib;
{
  # Configure & Theme Waybar
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = [
      {
        layer = "top";
        position = "top";
        modules-center = [ "hyprland/workspaces" ];
        modules-left = [
          "custom/startmenu"
          "hyprland/window"
          "pulseaudio"
          "memory"
          "disk"
          "idle_inhibitor"
        ];
        modules-right = [
          "custom/hyprbindings"
          "custom/notification"
          "custom/exit"
          "custom/gpu-usage"
          "custom/gputemperature"
          "cpu"
          "temperature"
          "network"
          "tray"
          "clock"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          format-icons = {
            default = " ";
            active = " ";
            urgent = " ";
          };
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
        };
        "clock" = {
          format = ''{:%a %d %b %Y %I:%M}'';
          tooltip = true;
          tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
        };
        "hyprland/window" = {
          max-length = 100;
          separate-outputs = false;
          format = "{initialTitle}";
          # rewrite = {
          #     "class<firefox>" =  "󰈹";
          #     "(.*) - Visual Studio Code" =  "Visual Studio Code";
          # };
        };
        "temperature" = {
          hwmon-path = "/sys/class/hwmon/hwmon0/temp1_input";
          critical-threshold = 80;
          format = "{icon} <span font-weight='bold'></span> {temperatureC}°C |";
          format-critical = "󰸁 {temperatureC}°C";
          format-icons = ["󱃃" "󰔏" "󱃂"];
        };
        "custom/gputemperature" = {
          exec = "nvidia-smi --query-gpu temperature.gpu --format=csv,noheader,nounits";
          interval = 2;
          format = "<span font-weight='bold'> </span>{}°C | ";
        };
        "memory" = {
          interval = 5;
          format = "  {used:0.1f}Gb ";
          tooltip = true;
        };
        "cpu" = {
          interval = 5;
          format = " CPU: {usage:2}%";
          tooltip = true;
        };
        "disk" = {
          format = "  {used}/{total}";
          tooltip = true;
        };
        "network"= {
            format= "{ifname}";
            format-wifi= "{essid} ({signalStrength}%) ";
            format-ethernet = "  {bandwidthDownBytes}  {bandwidthUpBytes} ";
            format-disconnected= "";
            tooltip-format= "{ifname} via {gwaddr} 󰊗";
            tooltip-format-wifi= "{essid} ({signalStrength}%) ";
            tooltip-format-ethernet= "{ifname} ";
            tooltip-format-disconnected= "Disconnected";
            format-icons= ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
            max-length= 50;
        };
        "tray" = {
          spacing = 12;
        };
        "pulseaudio" = {
          format = "{icon}  {volume}% {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          # format-source = " {volume}%";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "sleep 0.1 && pavucontrol";
        };
        "custom/exit" = {
          tooltip = false;
          format = "";
          on-click = "sleep 0.1 && wlogout";
        };
        "custom/startmenu" = {
          tooltip = false;
          format = "";
          # exec = "wofi --show drun";
          on-click = "sleep 0.1 && wofi --show drun";
        };
        
        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
          tooltip = "true";
        };
        "custom/notification" = {
          tooltip = false;
          format = "{icon} {}";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = "";
            inhibited-notification = "<span foreground='red'><sup></sup></span>";
            inhibited-none = "";
            dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
            dnd-inhibited-none = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "sleep 0.1 && task-waybar";
          escape = true;
        };
        "custom/gpu-usage" = {
          exec     = "bash -c 'nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits'";
          interval = 5;
          format   = "<span font-weight='bold'>󰾲 GPU: {}%</span>";  # use the expansion‑card icon
          tooltip  = false;
        };
      }
    ];
    style =  concatStrings [
      ''
        window.DP-2 * { font-size: 15pt; }
        * {
          font-size: 14px;
          border-radius: 0px;
          border: none;
          min-height: 0px;
        }
        window#waybar {
          background: rgba(0,0,0,0);
        }
        #workspaces {
          color: #${config.lib.stylix.colors.base00};
          margin: 4px 4px;
          padding: 5px 5px;
          border-radius: 16px;
        }
        #workspaces button {
          font-weight: bold;
          padding: 0px 5px;
          margin: 0px 3px;
          border-radius: 16px;
          color: #${config.lib.stylix.colors.base07};
          opacity: 0.5;
          transition: ${betterTransition};
        }
        #workspaces button.active {
          font-weight: bold;
          padding: 0px 5px;
          margin: 0px 3px;
          border-radius: 16px;
          color: #${config.lib.stylix.colors.base07};
          opacity: 1.0;
          min-width: 40px;
        }
        #workspaces button:hover {
          font-weight: bold;
          border-radius: 16px;
          color: #${config.lib.stylix.colors.base07};
          opacity: 0.8;
          transition: ${betterTransition};
        }
        tooltip {
          background: #${config.lib.stylix.colors.base01};
          border: 1px solid #${config.lib.stylix.colors.base07};
          border-radius: 12px;
        }
        tooltip label {
          color: #${config.lib.stylix.colors.base07};
        }
        #network.ethernet {
           color: #${config.lib.stylix.colors.base07};
        }
        #window,#temperature,#disk, #network , #custom-gputemperature,#custom-gpu-usage, #pulseaudio, #cpu, #memory, #idle_inhibitor {
          font-weight: normal;
          margin: 4px 0px;
          margin-left: 7px;
          padding: 0px 9px;
          color: #${config.lib.stylix.colors.base07};
          border-radius: 24px 10px 24px 10px;
        }
        #window {
          font-weight: bold;
          margin: 4px 0px;
          margin-left: 7px;
          padding: 0px 9px;
          color: #${config.lib.stylix.colors.base07};
          border-radius: 24px 10px 24px 10px;
        }
        #custom-startmenu {
          color: #${config.lib.stylix.colors.base07};
          font-size: 20px;
          padding: 0px 9px;
        }
        #network, #battery,
        #custom-notification, #tray, #custom-exit {
          font-weight: bold;
          color: #${config.lib.stylix.colors.base00};
          margin: 4px 0px;
          margin-right: 7px;
          border-radius: 10px 24px 10px 24px;
          padding: 0px 12px;
        }
        #clock {
          font-weight: bold;
          font-family: "Liga SFMono Nerd Font";
          color: #${config.lib.stylix.colors.base07};
          margin: 0px;
          padding: 0px 9px 0px 12px;
          border-radius: 0px 0px 0px 40px;
        }


      ''
      
      ];

  };
}
