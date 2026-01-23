{ lib, config, ... }:

{
  options = {
    userSettings.haskell = {
      enable = lib.mkEnableOption "Enable all things Haskell!";
    };
  };

  config = lib.mkIf config.systemSettings.haskell.enable {
    programs.vscode.haskell.enable = true;
    services.hoogle.enable = true;
    home.packages = with pkgs; [
      stack 
      cabal-install
      ghc 
    ];
  };
}