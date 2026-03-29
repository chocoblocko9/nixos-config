{ config, pkgs, ... }:

{
  hjem.users.${config.userName} = {
    packages = [ pkgs.hyprsunset ];

    files.".config/hypr/hyprsunset.conf".source = ./hyprsunset.conf;
  };
}
