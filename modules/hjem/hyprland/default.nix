{ lib, config, pkgs, ... }:

{
  imports = [ 
    # ./configs/slip.nix
    # ./configs/sleepless.nix
  ];

  options = {
    hjemSettings.hyprland = {
      enable = lib.mkEnableOption "Enable hyprland";
      profile = lib.mkOption { 
        default = "slip";  
        type = lib.types.str;
      };
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
        ".config/hypr/hyprland.conf".text = ((builtins.readFile ./hyprland.conf) 
        + (lib.optionalString (config.hjemSettings.hyprland.profile == "slip") (builtins.readFile ./slip.conf)
        + (lib.optionalString (config.hjemSettings.hyprland.profile == "sleepless") (builtins.readFile ./sleepless.conf))));
        */
        ".config/hypr/hyprland.conf".text = ''
          ${lib.optionalString (config.networking.hostName == "slip") "env = SLIP,1"}
          ${lib.optionalString (config.networking.hostName == "sleepless") "env = SLEEPLESS,1"}

          ### EXECUTE ON BOOT ###
          exec-once=runapp soteria
          exec-once=runapp kitty --class kitty-nvim --config ~/.files/modules/hjem/kitty/nvim.conf nvim
          exec-once=runapp quickshell
          exec-once=runapp lollypop

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
