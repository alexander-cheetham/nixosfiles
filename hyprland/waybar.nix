{ pkgs, lib, config, ... }:

let
  transitionFast = "opacity .22s ease, transform .22s ease";
  # Workday countdown configuration
  # Update targetDate and eventName as needed
  workdayCountdownConfig = {
    eventName = "Q1 Goal";
    targetDate = "2026-03-31";
    timezone = "Europe/London";
    workdays = [ 1 2 3 4 5 ]; # ISO weekday numbers (1 = Monday)
    holidays = [
      # Add holidays here as needed, e.g.:
      # { date = "2026-04-10"; label = "Good Friday"; category = "Holiday"; }
    ];
  };
  workdayCountdownConfigFile = pkgs.writeText "workday-countdown.json" (builtins.toJSON workdayCountdownConfig);
  workdayCountdownScript = pkgs.writeShellApplication {
    name = "workday-countdown";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      set -euo pipefail
      ${pkgs.python3}/bin/python - <<'PY'
import json
from datetime import date, datetime, timedelta
from zoneinfo import ZoneInfo

CONFIG_PATH = "${workdayCountdownConfigFile}"

with open(CONFIG_PATH, "r", encoding="utf-8") as fh:
    cfg = json.load(fh)

event_name = cfg.get("eventName", "Event")
target_date = date.fromisoformat(cfg["targetDate"])
timezone_name = cfg.get("timezone", "UTC")
try:
    tz = ZoneInfo(timezone_name)
except Exception:
    tz = ZoneInfo("UTC")

today = datetime.now(tz).date()
workdays = set(cfg.get("workdays", [1, 2, 3, 4, 5]))
holiday_entries = cfg.get("holidays", [])

excluded = {}
for entry in holiday_entries:
    d = date.fromisoformat(entry["date"])
    label = entry.get("label", "Holiday")
    category = entry.get("category")
    descriptor = f"{label}" + (f" ({category})" if category else "")
    excluded.setdefault(d, []).append(descriptor)

working_days_remaining = 0
holiday_hits = []
cursor = today
while cursor < target_date:
    labels = excluded.get(cursor, [])
    if cursor.isoweekday() in workdays and not labels:
        working_days_remaining += 1
    if labels:
        holiday_hits.append(f"{cursor.isoformat()} – {', '.join(labels)}")
    cursor += timedelta(days=1)

calendar_days = max((target_date - today).days, 0)
if target_date <= today:
    text = f"0 days until {event_name}"
    css_class = "countdown-complete"
else:
    text = f"{working_days_remaining} days until {event_name}"
    if working_days_remaining <= 3:
        css_class = "countdown-urgent"
    elif working_days_remaining <= 10:
        css_class = "countdown-warn"
    else:
        css_class = "countdown-ok"

holiday_tooltip = "\n".join(holiday_hits) if holiday_hits else "No upcoming holiday exclusions."
tooltip = "\n".join([
    f"{event_name} on {target_date.strftime('%A, %d %B %Y')}",
    f"Calendar days remaining: {calendar_days}",
    f"Working days remaining: {working_days_remaining}",
    "",
    "Excluded holidays:",
    holiday_tooltip,
])

print(json.dumps({
    "text": text,
    "tooltip": tooltip,
    "class": css_class,
}))
PY
    '';
  };
in
with lib; {
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    # --- Waybar JSON settings ---
    settings = [
      {
        layer = "top";
        position = "top";

        modules-center = [ "hyprland/workspaces" ];

        modules-left = [
          "custom/startmenu"
          "hyprland/window"
          "wireplumber"
          "group/hw"          # CPU + MEM + temps, nice and compact
          "disk"
          "custom/workday-countdown"
          "idle_inhibitor"
        ];

        modules-right = [
          "custom/gpu-usage"      # utilization via nvidia-smi
          "custom/gpu-temp"       # GPU temp via nvidia-smi
          "network"
          "tray"
          "custom/notification"
          "clock"
          "custom/exit"
        ];

        # ---------- Hyprland ----------
        "hyprland/workspaces" = {
          format = "{name}";
          format-icons = { default = " "; active = " "; urgent = " "; };
          show-special = true;
          special-visible-only = true;
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
        };

        "hyprland/window" = {
          # Docs list format/rewrite/separate-outputs; icon/max-length also work. :contentReference[oaicite:5]{index=5}
          format = "{initialTitle}";
          icon = true;
          max-length = 80;
          separate-outputs = true;  # per-monitor title
          rewrite = {
            "(.*) - Visual Studio Code" = "  \\1";
            "class<firefox>" = "󰈹  Firefox";
          };
        };

        # ---------- Time ----------
       "clock"= { 
        "format"= "<span>{0:%a %d %b %Y}</span>\n<span weight='bold'>{0:%H:%M}</span>"; 
        "tooltip"= true; "tooltip-format"= "<big>{0:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>"; 
        "justify"= "center";
        };



        # ---------- Audio (PipeWire) ----------
        "wireplumber" = {
          format = "{volume}% {icon}";
          format-muted = "";
          format-icons = [ "" "" "" ];
          on-click = "sleep 0.1 && pavucontrol";
        };

        # ---------- Hardware group ----------
        "group/hw" = {
          orientation = "horizontal";
          modules = [  "memory" "cpu" "temperature#cpu" ];
        };

        "cpu" = {
          interval = 5;
          format = "|  {usage:2}%";
          tooltip = true;
          on-click = "foot -e btop";   # adjust terminal if needed
        };

        "memory" = {
          interval = 5;
          format = "  {used:0.1f}Gb";
          tooltip = true;
          on-click = "foot -e btop";
        };

        "temperature#cpu" = {
          interval = 5;
          # AMD Ryzen 7950X: hwmon1/temp1_input exposes the consolidated Tctl sensor
          hwmon-path = [
            "/sys/class/hwmon/hwmon1/temp1_input"
          ];
          format = "CPU {temperatureC}°C |";
          tooltip = true;
          critical-threshold = 85;
        };

        "custom/gpu-temp" = {
          interval = 5;
          exec = "sh -c 'nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo --'";
          return-type = "text";
          format = "GPU {}°C |";
          tooltip = true;
        };

        # Keep your original nvidia-smi module as a fallback or utilization readout
        "custom/gpu-usage" = {
          exec     = "bash -c 'nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits'";
          interval = 10;  # relaxed to avoid waking GPU unnecessarily
          format   = "<span font-weight='bold'>󰾲 GPU: {}%</span>";
          tooltip  = false;
        };

        # Disk
        "disk" = {
          format = "  {used}/{total}";
          tooltip = true;
        };

        "custom/workday-countdown" = {
          interval = 60;
          exec = "${workdayCountdownScript}/bin/workday-countdown";
          return-type = "json";
          tooltip = true;
        };


        # Network with padded bandwidth (stable width). See module docs. :contentReference[oaicite:7]{index=7}
        "network" = {
          format = "{ifname}";
          format-wifi = " {bandwidthDownBytes:>9}  {bandwidthUpBytes:>9}  {essid} ({signalStrength}%) ";
          format-ethernet = " {bandwidthDownBytes:>9}  {bandwidthUpBytes:>9}";
          format-disconnected = "";
          tooltip-format = "{ifname} via {gwaddr} 󰊗";
          tooltip-format-wifi = "{essid} ({signalStrength}%) ";
          tooltip-format-ethernet = "{ifname} ";
          max-length = 50;
          on-click = "nm-connection-editor";
        };

        "tray" = { spacing = 12; };

        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = { activated = ""; deactivated = ""; };
          tooltip = true;
        };

        "custom/notification" = {
          tooltip = false;
          format = "{} {icon}";
          format-icons = {
            notification = "󱅫";
            none = "";
            "dnd-notification" = " ";
            "dnd-none" = "󰂛";
            "inhibited-notification" = " ";
            "inhibited-none" = "";
            "dnd-inhibited-notification" = " ";
            "dnd-inhibited-none" = " ";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "sleep 0.1 && swaync-client -t -sw";
          on-click-right = "sleep 0.1 && swaync-client -d -sw";
          escape = true;
        };

        "custom/startmenu" = {
          tooltip = false;
          format = "";
          on-click = "sleep 0.1 && wofi --show drun";
        };

        "custom/exit" = {
          tooltip = false;
          format = "";
          on-click = "sleep 0.1 && wlogout";
        };
      }
    ];

    # --- CSS (uses Stylix colors you already have) ---
    style = concatStrings [
      ''
      window.DP-2 * { font-size: 15pt; }
      window#waybar, window#waybar * {
        font-size: 13px;
        min-height: 0px;
      }
      window#waybar { background: rgba(0,0,0,0); }

      /* Tray menu */
      #tray menu, #tray menu * {
        font-family: "SF Pro Sans";
        font-size: 13px;
      }
      #tray menu {
        background: #${config.lib.stylix.colors.base01};
        border: 1px solid #${config.lib.stylix.colors.base05};
        border-radius: 12px;
        padding: 6px 8px;
        /* Optional blur if compositor supports it
           backdrop-filter: blur(10px); */
      }
      #tray menu menuitem {
        padding: 6px 12px;
        border-radius: 8px;
        transition: ${transitionFast};
      }
      #tray menu menuitem:hover {
        background: #${config.lib.stylix.colors.base02};
        color: #${config.lib.stylix.colors.base07};
      }

      /* Workspaces */
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
        transition: ${transitionFast};
      }
      #workspaces button.active {
        opacity: 1.0;
        min-width: 40px;
      }
      #workspaces button:hover {
        color: #${config.lib.stylix.colors.base07};
        opacity: 0.8;
      }

      /* Tooltips */
      tooltip {
        background: #${config.lib.stylix.colors.base01};
        border: 1px solid #${config.lib.stylix.colors.base07};
        border-radius: 12px;
      }
      tooltip label {
        color: #${config.lib.stylix.colors.base07};
        font-size: 0.75em;
      }

      #network.ethernet { color: #${config.lib.stylix.colors.base07}; }

      /* General modules */
      #window,
      #temperature, #temperature.cpu, #custom-gpu-temp,
      #disk, #custom-workday-countdown,
      #network, #custom-gpu-usage, #wireplumber,
      #cpu, #memory, #idle_inhibitor, #notification {
        font-weight: normal;
        margin: 4px 0px;
        margin-left: 7px;
        padding: 0px 9px;
        color: #${config.lib.stylix.colors.base07};
        border-radius: 24px 10px 24px 10px;
        transition: ${transitionFast};
      }

      /* Start menu icon */
      #custom-startmenu {
        color: #${config.lib.stylix.colors.base07};
        font-size: 20px;
        padding: 0px 9px;
      }

      /* Right-side accent blocks */
      #network, #battery, #tray, #custom-exit {
        font-weight: bold;
        color: #${config.lib.stylix.colors.base07};
        margin: 4px 0px;
        margin-right: 7px;
        border-radius: 10px 24px 10px 24px;
        padding: 0px 12px;
      }
      #custom-notification {
        font-weight: bold;
        color: #${config.lib.stylix.colors.base07};
        margin: 4px 0px;
        margin-right: 7px;
        border-radius: 10px 24px 10px 24px;
        padding: 0px 12px;
      }

      /* Clock: two-line block with rounded corner */
      #clock {
        font-weight: bold;
        font-family: "Liga SFMono Nerd Font";
        color: #${config.lib.stylix.colors.base07};
        margin: 0px;
        padding: 0px 9px 0px 12px;
        border-radius: 0px 0px 0px 40px;
      }

      #custom-workday-countdown {
        font-weight: bold;
        border-radius: 24px;
      }
      #custom-workday-countdown.countdown-ok {
        color: #${config.lib.stylix.colors.base08};
      }
      #custom-workday-countdown.countdown-warn {
        color: #${config.lib.stylix.colors.base09};
      }
      #custom-workday-countdown.countdown-urgent {
        color: #${config.lib.stylix.colors.base08};
      }
      #custom-workday-countdown.countdown-complete {
        color: #${config.lib.stylix.colors.base0A};
      }
      ''
    ];
  };
}
