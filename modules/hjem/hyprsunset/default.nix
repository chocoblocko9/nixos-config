{ pkgs, ... }:

{
  hjem.users.conor = {
    packages = [ pkgs.hyprsunset ];

    files.".config/hypr/hyprsunset.conf".source = ./hyprsunset.conf;
  };
}
