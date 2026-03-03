{ lib, config, pkgs, ... }:

{
  options = {
    systemSettings.shell = {
      enable = lib.mkEnableOption "Enable zsh with settings and stuff";
    };
  };

  config = lib.mkIf config.systemSettings.shell.enable {
    users.defaultUserShell = pkgs.zsh;

    environment.shellAliases = {
      ll = "ls -la";                                                                  
      icat = "kitten icat";
      nho = "nh os switch";
      update = "nix flake update --flake ~/.files && nh os switch";
    };

    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        theme = "gentoo";
        # theme = "fino-time"; 
      };
    };

    console.colors = [
      "011e25" # background
      "dc322f" # red
      "19cb00" # green
      "cecb00" # yellow
      "0d73cc" # blue
      "cd1ed1" # magenta
      "0dcdcd" # cyan

      "cac6b8"
      "657b83"
      "dc322f" # red
      "19cb00" # green
      "cecb00" # yellow
      "0d73cc" # blue
      "cd1ed1" # magenta
      "0dcdcd" # cyan
      "fdf6e3"
    ];
  };
}
