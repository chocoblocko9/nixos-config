{ lib, config, pkgs, ... }:

{
  options = {
    systemSettings.ly = {
      enable = lib.mkEnableOption "Enable ly display manager";
      profile = {
        "slip" = lib.mkEnableOption "Use profile slip";
        "sleepless" = lib.mkEnableOption "Use profile sleepless";
      };
    };
  };

  config = lib.mkIf config.systemSettings.ly.enable {
    services.displayManager.ly = {
      enable = true;
      settings = (lib.mkIf config.systemSettings.ly.profile.slip {
        setup_cmd = "~/.files/modules/system/ly/lysetup.sh";
  
        # Config
        allow_empty_password = false;
        auth_fails = "8"; 
        default_input = "login";    
        full_color = true;
        save = true; # Future me: idk what this does either tbh lol
  
        # Keybinds
        shutdown_key = "F1";
        shutdown_cmd = "systemctl poweroff";
        restart_key = "F2";
        restart_cmd = "systemctl reboot";
        sleep_key = "F3";
        sleep_cmd = "systemctl sleep";
        brightness_down_key = "F5";
        brightness_up_key = "F6";
        # PATH no worky I guess
        brightness_down_cmd = "/run/current-system/sw/bin/ddcutil --sleep-multiplier .1 --bus=5 setvcp 10 - 10";
        brightness_up_cmd = "/run/current-system/sw/bin/ddcutil --sleep-multiplier .1 --bus=5 setvcp 10 + 10";
  
        # Styling
        animation = "colormix";
        colormix_col1 = "0xFF000000";
        colormix_col2 = "0x00009494";
        # colormix_col1 = "0x0066FF33";
        colormix_col3 = "0x00000080";
        asterisk = ">";
        bg = "0x00000000";
        bigclock = "en";
        bigclock_seconds = "true"; 
        clock = "%H:%M:%S %a, %d/%m/%Y";  
      }) 
      
      // # Allows choosing between ly profiles
      
      (lib.mkIf config.systemSettings.ly.profile.sleepless {
        setup_cmd = "~/.files/modules/system/ly/lysetup.sh";
  
        # Config
        allow_empty_password = false;
        auth_fails = "8"; 
        default_input = "login";    
        full_color = true;
        save = true; # Future me: idk what this does either tbh lol
  
        # Keybinds
        shutdown_key = "F1";
        shutdown_cmd = "systemctl poweroff";
        restart_key = "F2";
        restart_cmd = "systemctl reboot";
        sleep_key = "F3";
        sleep_cmd = "systemctl sleep";
        brightness_down_key = "F5";
        brightness_up_key = "F6";
        # PATH no worky I guess
        brightness_down_cmd = "/run/current-system/sw/bin/ddcutil --sleep-multiplier .1 --bus=5 setvcp 10 - 10";
        brightness_up_cmd = "/run/current-system/sw/bin/ddcutil --sleep-multiplier .1 --bus=5 setvcp 10 + 10";
  
        # Styling
        animation = "colormix";
        colormix_col1 = "0xFF000000";
        colormix_col2 = "0x00009494";
        # colormix_col1 = "0x0066FF33";
        colormix_col3 = "0x00000080";
        asterisk = ">";
        bg = "0x00000000";
        bigclock = "en";
        bigclock_seconds = "true"; 
        clock = "%H:%M:%S %a, %d/%m/%Y";  
      });
    };

    # Make brightness changing work
    hardware.i2c.enable = true;
    environment.systemPackages = [ pkgs.ddcutil ];
  };
}
