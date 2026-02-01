{ lib, config, pkgs, ... }:

{
  options = {
    userSettings.vscode = {
      enable = lib.mkEnableOption "Enable Visual Studio Code";
    };
  };

  config = lib.mkIf config.userSettings.vscode.enable {
    programs.vscode = {
      enable = true;
      profiles.conor.extensions = with pkgs.vscode-extensions; [ 
        jnoortheen.nix-ide
        justusadam.language-haskell
        haskell.haskell
        ms-python.debugpy
        ms-python.python
        ms-python.vscode-pylance
        github.copilot
        github.copilot-chat
      ];
    };
  };
}