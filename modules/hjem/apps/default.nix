{ pkgs, ... }:

{
  hjem.users.conor = {
    packages = with pkgs; [
      # Programs
      vlc
      vesktop 

      # Tools
      fastfetch
      zip
      libnotify
      socat
      ffmpeg
      wf-recorder
      unzip
      xarchiver # GUI archive manager
      ncdu 
      wev 
      unipicker

      # Game dev
      godot 
      libresprite 

      # Music
      mprisence # discord RPC using mpris2
      lollypop # GNOME music player (my beloved)
      mpris-scrobbler # Last.fm scrobbler for mpris2
      nicotine-plus # Soulseek
      puddletag # song file tagger
      cava # visualiser
      playerctl # useful for mpris stuff
    ];

    # files.".config/apps/apps.conf".text = ''
    # '';
  };
}
