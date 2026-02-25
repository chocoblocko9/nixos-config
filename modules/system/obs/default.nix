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
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-livesplit-one
        obs-gradient-source
        obs-plugin-countdown
        obs-pipewire-audio-capture
      ];
  	};
  };
}
