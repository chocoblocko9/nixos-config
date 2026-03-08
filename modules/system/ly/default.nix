{ lib, config, pkgs, ... }:

{

  imports = [
    ./configs/slip.nix
    ./configs/superliminal.nix
    ./configs/sleepless.nix
  ];

  options = {
    systemSettings.ly = {
      enable = lib.mkEnableOption "Enable ly display manager";
      profile = lib.mkOption { 
        default = "slip";  
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf config.systemSettings.ly.enable {
    services.displayManager.ly = {
      enable = true;
      settings = {
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

        # Styling
        bigclock = "en";
        bigclock_seconds = "true";
      };
    };

    # Make brightness changing work
    hardware.i2c.enable = true;
    environment.systemPackages = [ 
      pkgs.ddcutil 
      pkgs.brightnessctl
    ];
  };
}
