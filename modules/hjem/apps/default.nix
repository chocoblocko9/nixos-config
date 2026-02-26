{ lib, config, pkgs, ... }:

{
  options = {
    hjemSettings.apps = {
      enable = lib.mkEnableOption "Enable apps";
    };
  };

  config = lib.mkIf config.hjemSettings.apps.enable {
    hjem.users.${config.userName} = {
      packages = with pkgs; [
        # Programs
        vlc

        # Tools
        fastfetch
        zip
        unzip
        feh # GUI image viewer
        xarchiver # GUI archive manager
        ncdu 
        wev 
        unipicker
      ];

      # files.".config/apps/apps.conf".text = ''
      # '';
    };
  };
}
