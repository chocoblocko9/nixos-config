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
        ".config/hypr/hyprland".source = ./hyprland;

        /*  
        Exports an environment variable to hyprland that conditionals can use to choose
        what config options to pick. This puts all branching into my config files which
        is nice and also means I don't have to do the silly builtins.readFile stuff.
        */
        ".config/hypr/hyprland.conf".text = ''
          ${lib.optionalString (config.networking.hostName == "slip") "env = SLIP,1"}
          ${lib.optionalString (config.networking.hostName == "sleepless") "env = SLEEPLESS,1"}

          source = ~/.config/hypr/hyprland/*
        '';

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
