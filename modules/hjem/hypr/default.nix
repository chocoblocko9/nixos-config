{ config, lib, pkgs, ... }:

{
  options.hjemSettings.hyprland.enable = lib.mkEnableOption "Enable hypr* things";

  config = lib.mkIf config.hjemSettings.hyprland.enable {
    hjem.users.conor = {
      packages = [ 
        pkgs.hyprsunset
        pkgs.hyprpaper
        pkgs.hyprpicker
        pkgs.hyprshutdown

        pkgs.grim
        pkgs.slurp
        pkgs.wl-clipboard
      ];

      files = {
        #".config/hypr/hyprland".source = ./hyprland;
        ".config/hypr/hyprsunset.conf".source = ./hyprsunset.conf;

        ".config/hypr/hyprland.lua".text = /* lua */ ''
          -- Nix
          host = "${config.networking.hostName}"
          
          -- Import
          require("hyprland/functions")

          require("hyprland/animations")
          require("hyprland/autostart")
          require("hyprland/binds")
          require("hyprland/env")
          require("hyprland/general")
          require("hyprland/input")
          require("hyprland/rules")
          require("hyprland/workspaces")
        '';

        ".config/hypr/xdph.conf".text = /* hyprlang */ ''
          screencopy {
            max_fps = 60
            allow_token_by_default = true
          }
        '';

        ".config/hypr/hyprpaper.conf".text = /* hyprlang */ ''
          wallpaper {
            monitor =
            fit_mode = cover
            path = ~/.files/modules/hjem/hypr/wallpapers/pawel-czerwinski-cyan-fish.jpg
          }
          ipc = true
          splash = false
        '';

        ".config/hypr/stubs".source = "/run/current-system/sw/share/hypr/stubs";

        ".config/hypr/.luarc.json" = {
          generator = lib.generators.toJSON {};

          value = {
            "runtime.version" = "Lua 5.5";
            "workspace.checkThirdParty" = false;
            "diagnostics.globals" = [ "hl" ];
            "workspace.library" =  [ "./stubs" ];
          };
        };
      };
    };
  };
}
