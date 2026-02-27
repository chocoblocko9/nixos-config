{ lib, config, pkgs, ... }:

{
  options = {
    hjemSettings.music = {
      enable = lib.mkEnableOption "Enable music related stuff";
    };
  };

  config = lib.mkIf config.hjemSettings.music.enable {
    hjem.users.${config.userName} = {
      packages = with pkgs; [
        mprisence # discord RPC using mpris2
        lollypop # GNOME music player (my beloved)
        mpris-scrobbler # Last.fm scrobbler for mpris2
        nicotine-plus # Soulseek
        puddletag # song file tagger
        cava # visualiser
      ]; 
    };
  };
}
