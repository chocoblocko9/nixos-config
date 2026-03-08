{ lib, config, pkgs, ... }:

{
  options = {
    systemSettings.obs = {
      enable = lib.mkEnableOption "Enable OBS Studio";
    };
  };

  config = lib.mkIf config.systemSettings.obs.enable {
    programs.obs-studio = {
			enable = true;
	  	enableVirtualCamera = true;
      plugins = [
        pkgs.obs-studio-plugins.wlrobs
        pkgs.obs-studio-plugins.obs-livesplit-one
        pkgs.obs-studio-plugins.obs-gradient-source
        pkgs.obs-studio-plugins.obs-plugin-countdown
        pkgs.obs-studio-plugins.obs-pipewire-audio-capture
      ];
  	};
  };
}
