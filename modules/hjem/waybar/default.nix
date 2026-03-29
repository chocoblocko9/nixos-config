{ lib, config, pkgs, ... }:

{
  options = {
    hjemSettings.waybar = {
      enable = lib.mkEnableOption "Enable waybar";
    };
  };

  config = lib.mkIf config.hjemSettings.waybar.enable {
    hjem.users.conor = {
      packages = with pkgs; [ 
        waybar 
        waybar-mpris
      ];

      files = {
        ".config/waybar/config".source = ./config;
        ".config/waybar/style.css".source = ./style.css;
      };
    };
  };
}
