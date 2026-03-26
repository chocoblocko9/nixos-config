{ lib, config, pkgs, ... }:

{
  options = {
    hjemSettings.hyprland = {
      enable = lib.mkEnableOption "Enable hyprland";
    };
  };

  config = lib.mkIf config.hjemSettings.hyprland.enable {
    hjem.users.${config.userName} = {
      packages = with pkgs; [ 
        hyprpicker
        hyprshutdown
        grim
        slurp
        wl-clipboard

        runapp

        # Script stuff
        xdotool
        socat
        jq
      ];

      files = {
        #".config/hypr/hyprland".source = ./hyprland;

        /*  
        It would be nice to do this in lua and in fact I can but this is cleaner cus 
        os.getenv("HOST") doesn't work for unknown reasons, subject to change
        ".config/hypr/hyprland.lua".text = ''
          ${lib.optionalString (config.networking.hostName == "slip") "global host = \"slip\""}
          ${lib.optionalString (config.networking.hostName == "sleepless") "global host = \"sleepless\""}

          require(binds)
        '';
        */

        ".config/hypr/xdph.conf".text = ''
          screencopy {
            max_fps = 60
            allow_token_by_default = true
          }
        '';
      };
    };
  };
}
