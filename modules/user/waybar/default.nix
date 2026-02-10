{ lib, config, pkgs, ... }:

{
  options = {
    userSettings.waybar = {
      enable = lib.mkEnableOption "Enable Waybar";
    };
  };

  config = lib.mkIf config.userSettings.waybar.enable {
    home.packages = with pkgs; [
      waybar-mpris
    ];

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 36;
          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "wireplumber" "custom/waybar-mpris" ];
          modules-right = [ 
            #"group/group-power" 
            "backlight/slider"
            "battery"
            "tray" 
            "clock" 
          ];

          "mpris" = {
            format = "{title} by {artist} on {album} <small>[{position}/{length}]</small> / ({status} {status_icon})";
            player = "playerctld";
            ignored-players = [ "firefox" ];
            interval = 1;
            dynamic-len = 50;
            status-icons = {
		          paused = "⏸";
	            playing = "▶";
              stopped = "⏹";
            };
          };

          "battery" = {
            format = "{capacity}% {icon}";
            format-icons = {
              default = ["󰂎 " "󰁺 " "󰁻 " "󰁼 " "󰁽 " "󰁾 " "󰁿 " "󰂀 " "󰂁 " "󰂂 " "󰁹 "];
              charging = ["󰢟 " "󰢜 " "󰂆 " "󰂇 " "󰂈 " "󰢝 " "󰂉 " "󰢞 " "󰂊 " "󰂋 " "󰂅 "];
              # full
            };
            states = {
              warning = 25;
              critical = 10;
            };
          };

          "custom/waybar-mpris" = {
            return-type = "json";
            exec = "waybar-mpris --position --pause \"▶\" --play \"⏸\" --order \"ARTIST:TITLE:POSITION\"";
            on-click = "waybar-mpris --send toggle";

            on-scroll-up = "waybar-mpris --send next";
            on-scroll-down = "waybar-mpris --send prev";
            on-click-right = "waybar-mpris --send player-next";
            on-click-forward = "waybar-mpris --send prev";
            escape = true;
          };

          "backlight/slider" = {
            min = 0;
            max = 100;
            orientation = "horizontal";
          };

          "wireplumber" = {
            format = "{volume}% {icon} |";
            format-muted = "";
            on-click = "pavucontrol";
            format-icons = [" " " " " "];
          };

          "memory" = {
            format = "{used} / {total} ({percentage}%)";
          };

          "group/group-power" = {
            orientation = "inherit";
            drawer = {
                transition-duration = 500;
                children-class = "not-power";
                transition-left-to-right = false;
            };
            modules = [
              "custom/power"
              "custom/quit"
              "custom/lock"
              "custom/reboot"
            ];
          };

          "custom/quit" = {
            format = "󰗼";
            tooltip = false;
            on-click = "uwsm stop";
          };
          "custom/lock" = {
            format = "󰍁";
            tooltip = false;
            on-click = "swaylock";
          };
          "custom/reboot" = {
            format = "󰜉";
            tooltip = false;
            on-click = "reboot";
          };
          "custom/power" = {
            format = "";
            tooltip = false;
            on-click = "shutdown now";
          };
        };
      };
      style = ''
        * {
          font-size: 15px;
          color: #2aa198;
        }

        #pulseaudio-slider trough, #backlight-slider trough {
          min-height: 10px;
          min-width: 80px;
        }

        #backlight-slider highlight {
          background-color: #2aa198;
        }

        #backlight-slider slider {
          min-width: 5px;
          min-height: 10px;
          background-color: #2aa198;
        }

        #battery.warning {
          color: yellow;
        }

        #battery.critical {
          color: red;
        }
      ''; 
    };
  };
}
