{ lib, config, pkgs, ... }:

{
  options = {
    userSettings.music = {
      enable = lib.mkEnableOption "Enable music listening stuff";
    };
  };

  config = lib.mkIf config.userSettings.music.enable {
    services.playerctld.enable = true;

    home.packages = with pkgs; [
      mprisence # discord RPC using mpris2
      lollypop # GNOME music player (my beloved)
      mpris-scrobbler # Last.fm scrobbler for mpris2
      nicotine-plus # Soulseek
      puddletag # song file tagger
    ];
  };
}