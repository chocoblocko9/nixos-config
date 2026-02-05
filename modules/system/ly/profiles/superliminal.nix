{ lib, config, ... }:

let 
  cfg = config.systemSettings.ly.profile;
in {
  config.services.displayManager.ly = lib.mkIf (cfg == "superliminal") {
    settings = {
      # PATH no worky I guess
      brightness_down_cmd = "/run/current-system/sw/bin/ddcutil --sleep-multiplier .1 --bus=5 setvcp 10 - 10";
      brightness_up_cmd = "/run/current-system/sw/bin/ddcutil --sleep-multiplier .1 --bus=5 setvcp 10 + 10";

      # Styling
      animation = "colormix";
      colormix_col1 = "0xFF000000";
      colormix_col2 = "0x00009494";
      colormix_col3 = "0x00000080";
      asterisk = ">";
      bg = "0x00000000"; 
      clock = "%I:%M:%S %p %a, %d/%m/%Y";
    };
  };
}