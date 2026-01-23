{ lib, config, ... }:

{
  options = {
    userSettings.music = {
      enable = lib.mkEnableOption "Enable music listening stuff";
    };
  };

  config = lib.mkIf config.systemSettings.music.enable {
    services = {
      mpd = {
        enable = true;
        musicDirectory = "/home/conor/1TB-Hard-Drive/Bandcamp/";
        network.listenAddress = "any"; # if you want to allow non-localhost connections
        network.startWhenNeeded = true; # systemd feature: only start MPD service upon connection to its socket
        extraConfig = ''
          audio_output {
            type "pipewire"
            name "PipeWire Output"
          }

          audio_output {
            type "fifo"
            name "my_fifo"
            path "/tmp/mpd.fifo"
            format "44100:16:2"
          }
        '';
      };
    };

    # rmpc (MASSIVE work in progress)
    programs.rmpc = {
      enable = true;
  #    config = ''
  #      #![enable(implicit_some)]
  #      #![enable(unwrap_newtypes)]
  #      #![enable(unwrap_variant_newtypes)]
  #      (
  #        on_song_change: ["/home/conor/.files/scripts/rmpc/rmpc-notif"],
  #        tabs: [
  #        ( name: "Queue",  pane: Split
  #          ( direction: Horizontal,  panes: 
  #            [
  #              ( size: "40%", pane: Pane(AlbumArt)),
  #              ( size: "60%", pane: Split 
  #                ( direction: Vertical,  panes: 
  #                  [
  #                    ( size: "50%", pane: Pane(Queue)),
  #                    ( size: "50%", pane: Pane(Cava)),
  #                  ],
  #                ),
  #              ), 
  #            ],
  #          ),
  #        ),
  #        ( name: "Directories",  pane: Pane(Directories),  ),
  #        ( name: "Artists",  pane: Pane(Artists),  ),
  #        ( name: "Album Artists",  pane: Pane(AlbumArtists), ),
  #        ( name: "Albums", pane: Pane(Albums), ),
  #        ( name: "Playlists",  pane: Pane(Playlists),  ),
  #        ( name: "Search", pane: Pane(Search), ),
  #        ],
  #
  #        cava: (
  #          framerate: 60, // default 60
  #          autosens: true, // default true
  #          sensitivity: 100, // default 100
  #          lower_cutoff_freq: 50, // not passed to cava if not provided
  #          higher_cutoff_freq: 10000, // not passed to cava if not provided
  #          input: (
  #            method: Fifo,
  #            source: "/tmp/mpd.fifo",
  #            sample_rate: 44100,
  #            channels: 2,
  #            sample_bits: 16,
  #          ),
  #          smoothing: (
  #            noise_reduction: 77, // default 77
  #            monstercat: false, // default false
  #            waves: true, // default false
  #          ),  
  #        ),
  #      )
  #    '';
    };
  };
}