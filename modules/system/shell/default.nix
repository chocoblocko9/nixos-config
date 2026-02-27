{ lib, config, ... }:

{
  options = {
    systemSettings.shell = {
      enable = lib.mkEnableOption "Enable zsh with settings and stuff";
    };
  };

  config = lib.mkIf config.systemSettings.shell.enable {
    environment.shellAliases = {
      ll = "ls -la";                                                                  
      icat = "kitten icat";
      nho = "nh os switch";
      nhh = "nh home switch";
      update = "nix flake update --flake ~/.files && nh os switch && nh home switch";
    };

    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        # enable = true;
      };
    };
  };
}
