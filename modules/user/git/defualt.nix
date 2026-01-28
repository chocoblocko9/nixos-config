{ lib, config, pkgs, ... }:

{
  options = {
    userSettings.git = {
      enable = lib.mkEnableOption "Enable git";
    };
  };

  config = lib.mkIf config.userSettings.git.enable {
    programs.git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        user = {
          name = "Conor";
          email = "conorboyle07@protonmail.com";
        };
      };
    };
  };
}