{ lib, config, pkgs, ... }:

let 
  cfg = config.systemSettings.ly.profile;
in {
  config.services.displayManager.ly = lib.mkIf (cfg == "slip") {
    settings = {
      # Patch for hyprland with UWSM not booting for some reason
      setup_cmd = "~/.files/modules/system/ly/lysetup.sh";

      # PATH no worky I guess
      brightness_down_cmd = "${pkgs.ddcutil}/bin/ddcutil --sleep-multiplier .1 --bus=5 setvcp 10 - 10";
      brightness_up_cmd = "${pkgs.ddcutil}/bin/ddcutil --sleep-multiplier .1 --bus=5 setvcp 10 + 10";

      # Styling
      animation = "colormix";
      colormix_col1 = "0x20000000";
      colormix_col2 = "0x01009494";
      colormix_col3 = "0x01000080";
      asterisk = ">";
      bg = "0x20000000"; 
      clock = "%H:%M:%S %a, %d/%m/%Y";  
      bigclock_12hr = false;
    };
  };
}
