{ pkgs, ... }:

let 
  mlspp = pkgs.callPackage ../../derivations/acheron/mlspp { };
  
  acheron = pkgs.callPackage ../../derivations/acheron {
    inherit mlspp;
  };

  lollypop' = pkgs.lollypop.override {
    youtubeSupport = false;
  };
in
{
  hjem.users.conor = {
    packages = [
      # Programs
      pkgs.vlc
      pkgs.vesktop 
      acheron

      # Tools
      pkgs.fastfetch
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
      lollypop' # GNOME music player (my beloved)
      pkgs.mpris-scrobbler # Last.fm scrobbler for mpris2
      pkgs.nicotine-plus # Soulseek
      pkgs.puddletag # song file tagger
      pkgs.cava # visualiser
      pkgs.playerctl # useful for mpris stuff
    ];

    # files.".config/apps/apps.conf".text = ''
    # '';
  };
}
