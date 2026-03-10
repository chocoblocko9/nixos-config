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
        playerctl # useful for mpris stuff
      ];

      systemd.services.mpris-scrobbler = {
        enable = true;
        wantedBy = [ "default.target" ];

        unitConfig = {
          Description = "Daemon to scrobble tracks loaded from the MPRIS DBus interface to compatible services";
          Documentation = "man:mpris-scrobbler(1)";
          Requires = [ "dbus.socket" ];
        };

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.mpris-scrobbler}/bin/mpris-scrobbler -vv";
          Restart = "on-failure";
          Environment = "XDG_DATA_HOME=%h/.local/share";
          ExecReload = "/bin/kill -HUP $MAINPID";
          CPUQuota = "1%";
          RestartSec = 30;
          PassEnvironment = "PROXY";
        };
      };
    };
/*
    systemd.services.mpris-scrobbler-help = {
      enable = true;
      wantedBy = [ "graphical-session.target" ];

      unitConfig = {
        Description = "cheese daemon to scrobble tracks loaded from the MPRIS DBus interface to compatible services";
        Documentation = "man:mpris-scrobbler(1)";
        Requires = [ "dbus.socket" ];
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.mpris-scrobbler}/bin/mpris-scrobbler -vv";
        Restart = "on-failure";
        Environment = "XDG_DATA_HOME=%h/.local/share";
        ExecReload = "/bin/kill -HUP $MAINPID";
        CPUQuota = "1%";
        RestartSec = 30;
        PassEnvironment = "PROXY";
      };    
    };
    */
  };
}
