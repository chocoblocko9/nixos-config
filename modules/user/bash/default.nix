{ lib, config, ... }:

{
  options = {
    userSettings.bash = {
      enable = lib.mkEnableOption "Enable bash (mostly aliases)";
    };
  };

  config = lib.mkIf config.userSettings.bash.enable {
    programs.bash = {
      enable = true;
      shellAliases = {
        # Aliases
        rebuild = "sudo nixos-rebuild switch --flake .";
        ll = "ls -la"; 
        icat = "kitten icat";
        nho = "nh os switch";
        nhh = "nh home switch";
        update = "nix flake update && nh os switch && nh home switch";
      };
    };
  };
}