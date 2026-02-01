{ lib, config, pkgs, ... }:

{
  options = {
    systemSettings.audio = {
      enable = lib.mkEnableOption "Enable audio related things";
    };
  };

  config = lib.mkIf config.systemSettings.audio.enable {
    # PipeWire uses this apparently? Debatable if it should be in here but whatever when amn't I enabling AUDIO
    security.rtkit.enable = true;

    services = {
      pulseaudio.enable = false;
      pipewire = {
        pulse.enable = true;
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      pavucontrol
    ];
  };
}