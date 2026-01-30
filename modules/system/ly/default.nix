{ lib, config, ... }:

{
  options = {
    systemSettings.ly = {
      enable = lib.mkEnableOption "Enable ly display manager";
    };
  };

  config = lib.mkIf config.systemSettings.ly.enable {
    services.displayManager.ly = {
      enable = true;
      settings = {
        # Uses local setup.sh file because it can't find default with home manager managing bash I think? I feel like that shouldn't be it but this makes it work so hey!
        setup_cmd = "./lysetup.sh";
  
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
        brightness_down_cmd = "/nix/store/881kbvkx60vfglagli4wqz0ascz2icni-ddcutil-2.2.1/bin/ddcutil --sleep-multiplier .1 --bus=8 setvcp 10 - 10"; # this is horrible horrible code that is gonna break 
        brightness_up_key = "F6";
        brightness_up_cmd = "/nix/store/881kbvkx60vfglagli4wqz0ascz2icni-ddcutil-2.2.1/bin/ddcutil --sleep-multiplier .1 --bus=8 setvcp 10 + 10"; # whenever i upgrade but whatever i WILL fix it cus i'll have to
  
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
      };
    };

    # Make brightness changing work
    hardware.i2c.enable = true;
    environment.systemPackages = [ pkgs.ddcutil ];
  };
}