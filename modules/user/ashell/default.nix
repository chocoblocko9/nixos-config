{ lib, config, ... }:

{
  options = {
    userSettings.ashell = {
      enable = lib.mkEnableOption "Enable ashell";
    };
  };

  config = lib.mkIf config.userSettings.ashell.enable {
    programs.ashell = {
      enable = true;
      systemd.enable = true;
      settings = {
        enable_esc_key = true;
        position = "Top";

        modules = {
          left = [ "Workspaces" "Tray" ];
          center = [ "MediaPlayer" ];
          right = [ "SystemInfo" [ "Clock" "Privacy" "Settings" ] ];
        }; 

        clock = {
          format = "%a %D %X";
        };

        system_info = {
          indicators = [ "Cpu" "Temperature" ];
        };

        system_info.temperature = {
          sensor = "k10temp Tctl";
        };

        setting = {
          shutdown_cmd = "systemctl poweroff";
          suspend_cmd = "systemctl sleep";
          reboot_cmd = "systemctl reboot";
          logout_cmd = "loginctl kill-user $(whoami)";
        };
      };
    };
  };
}