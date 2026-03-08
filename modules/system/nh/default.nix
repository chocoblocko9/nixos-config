{ lib, config, ... }:

{
  options = {
    systemSettings.nh = {
      enable = lib.mkEnableOption "Enable nh";
    };
  };

  config = lib.mkIf config.systemSettings.nh.enable {
    programs.nh = {
	    enable = true;
	    clean = {
        enable = true;
	      extraArgs = "--keep-since 7d --keep 5";
      };
	    flake = "/home/conor/.files/"; # sets NH_OS_FLAKE variable for you
	  };
  };
}
