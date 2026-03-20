{ lib, config, pkgs, ... }:

{
  options = {
    hjemSettings.dev = {
      enable = lib.mkEnableOption "Enable development stuff";
    };
  };

  config = lib.mkIf config.hjemSettings.dev.enable {
    hjem.users.${config.userName} = {
      packages = [ 
        pkgs.godot
        pkgs.libresprite
      ];
    };
  };
}
