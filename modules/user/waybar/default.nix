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
            "memory"
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
  
          "custom/waybar-mpris" = {
            return-type = "json";
            exec = "waybar-mpris --position --pause \"▶\" --play \"⏸\"";
            on-click = "waybar-mpris --send toggle";

            on-scroll-up = "waybar-mpris --send next";
            on-scroll-down = "waybar-mpris --send prev";
            on-click-right = "waybar-mpris --send player-next";
            escape = true;
          };

          "wireplumber" = {
            format = "{volume}% {icon}";
            format-muted = "";
            on-click = "helvum";
            format-icons = ["" "" ""];
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

      '';
    };
  };
}
