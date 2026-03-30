{ lib, config, ... }:

{
  options = {
    systemSettings.gaming = {
      enable = lib.mkEnableOption "Enable gaming related programs and settings";
    };
  };

  config = lib.mkIf config.systemSettings.gaming.enable {
    hardware.amdgpu = {
      opencl.enable = true;
      initrd.enable = true;
      overdrive = { # GPU overclocking stuff
        enable = true;
        ppfeaturemask = "0xfffd7fff";
      };
    };

    services = { 
      lact.enable = true;
      xserver.videoDrivers = [ "amdgpu" ];
    };

    programs = {
      steam = { 
        enable = true;
        gamescopeSession.enable = true;
      };
      
      gamemode.enable = true;
    };
  };
}
