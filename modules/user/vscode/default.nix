{ lib, config, ... }:

{
  options = {
    userSettings.vscode = {
      enable = lib.mkEnableOption "Enable Visual Studio Code";
    };
  };

  config = lib.mkIf config.userSettings.vscode.enable {
    programs.vscode = {
      enable = true;
#      profiles.conor.extensions = [ pkgs.vscode-extensions.jnoortheen.nix-ide ];
      haskell.enable = true;
    };
  };
}