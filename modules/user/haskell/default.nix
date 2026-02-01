{ lib, config, pkgs, ... }:

{
  options = {
    userSettings.haskell = {
      enable = lib.mkEnableOption "Enable all things Haskell!";
    };
  };

  config = lib.mkIf config.userSettings.haskell.enable {
    home.packages = with pkgs; [
      stack 
      cabal-install
      ghc 
    ];
  };
}