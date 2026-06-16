{ config, pkgs, lib, ... }:

let 
  mlspp = pkgs.callPackage ../../derivations/acheron/mlspp { };

  libdave = pkgs.callPackage ../../derivations/acheron/libdave { 
    inherit mlspp;
  };
  
  acheron = pkgs.callPackage ../../derivations/acheron {
    inherit libdave;
  };

  lollypop = pkgs.lollypop.override {
    youtubeSupport = false;
  };

  wewa = pkgs.callPackage ../../derivations/wewa {};
in {
  options.hjemSettings.apps.enable = lib.mkEnableOption "Enable apps I usually want";

  config = lib.mkIf config.hjemSettings.apps.enable {

  hjem.users.conor = {
    packages = [
      # Programs
      pkgs.vlc
      pkgs.vesktop 
      acheron
      wewa

      # Tools
      # pkgs.fastfetch
      pkgs.zip
      pkgs.libnotify
      pkgs.socat
      pkgs.ffmpeg
      pkgs.wf-recorder
      pkgs.unzip
      pkgs.xarchiver # GUI archive manager
      pkgs.ncdu 
      pkgs.wev 
      pkgs.unipicker
      pkgs.abaddon

      # Game dev
      pkgs.godot 
      pkgs.libresprite 

      # Music
      pkgs.mprisence # discord RPC using mpris2
      lollypop # GNOME music player (my beloved)
      pkgs.mpris-scrobbler # Last.fm scrobbler for mpris2
      pkgs.nicotine-plus # Soulseek
      pkgs.puddletag # song file tagger
      pkgs.cava # visualiser
      pkgs.playerctl # useful for mpris stuff
    ];

    # files.".config/apps/apps.conf".text = ''
    # '';
  };
};
}
