{ lib, config, ... }:

let 
  cfg = config.systemSettings.ly.profile;
in {
  config.services.displayManager.ly = lib.mkIf (cfg == "sleepless") {
    settings = {
      # Patch for hyprland with UWSM not booting for some reason
      setup_cmd = "~/.files/modules/system/ly/lysetup.sh";

      # PATH no worky I guess
      brightness_down_cmd = "/run/current-system/sw/bin/brightnessctl -q -n s 10%-";
      brightness_up_cmd = "/run/current-system/sw/bin/brightnessctl -q -n s +10%";

      # Styling
      battery_id = "BAT0";
      animation = "colormix";
      colormix_col1 = "0xFF000000";
      colormix_col2 = "0x00009494";
      # colormix_col1 = "0x0066FF33";
      colormix_col3 = "0x00000080";
      asterisk = ">";
      bg = "0x00000000"; 
      clock = "%H:%M:%S %a, %d/%m/%Y";  
      bigclock_12hr = false;
    };
  };
}