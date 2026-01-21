{ config, lib, pkgs, ... }:
{
  imports = [
    ./hypr/hyprland.nix
    ./hypr/hyprpaper.nix
    ./hypr/hyprsunset.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    username = "conor";
    homeDirectory = "/home/conor";
    stateVersion = "25.11";
  };

  # The home.packages option allows you to install Nix packages into your environment.
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    # Programs
    firefox
    heroic # Good games launcher
    cemu # Wii U my beloved
    prismlauncher
    parallel-launcher
    python315
    nicotine-plus # Soulseek
    jdk21_headless
    vlc

    # Tools
    pavucontrol
    fastfetch
    zip
    unzip
    nwg-look # GTK themes manager
    jq # hyprland minimise script needs this or smth
    mpd-discord-rpc # Shows currently playing music on MPD on discord rich presence, home-manager service was being weird unforunately
    feh # GUI image viewer
    xarchiver # GUI archive manager
		libsForQt5.qt5ct
		puddletag # song file tagger
    streamlink 
    ncdu 
    wev 
    unipicker
	
    # Themes
    adw-gtk3  
    numix-icon-theme
  
    # hyprland
    hyprpicker
    grim
    slurp
    wl-clipboard
 
    

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

	# qt
	qt = {
		enable = true;
		style.name = "adwaita-dark";
		style.package = pkgs.adwaita-qt;
	};

	
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

  # vscode
  programs.vscode = {
    enable = true;
#    profiles.conor.extensions = [ pkgs.vscode-extensions.jnoortheen.nix-ide ];
  };

  # btop
  programs.btop = {
    enable = true;
    package = pkgs.btop-rocm;
  };

  # dunst
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = "(0,400)";
        height = "(0,325)";
        offset = "(40,20)";
        origin = "top-right";
        frame_color = "#073642";
        background = "#000000C0";
#        background = "#09455480";
        progress_bar = "true";
        font = "Monospace 12";
      };
      urgency_normal = {};


    };
  };


  # Git
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      user = {
        name = "Conor";
        email = "conorboyle07@protonmail.com";
      };
    };
  };   

  # Bash  
  programs.bash = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ."; # Command is way too long to be typing out constantly
      ll = "ls -la"; 
      icat = "kitten icat";
      ets2 = "streamlink -p vlc -a \"-vvv - --sout \#transcode{vcodec=none,acodec=mp3,ab=320,scodec=none}:standard{access=http,mux=raw,dst=127.0.0.1:8080}\" --twitch-disable-hosting --twitch-disable-ads https://www.youtube.com/watch?v=edqlOxtnvL0 144p"; 
      # basically this starts a VLC HTTP stream at localhost:8080 of the mau5trap
      # Airplane Mode 24/7 stream and Euro Truck Simulator can then download that
      # and play it as an in-game radio because it functions like any over the 
      # internet radio. Cool? Cool.
    };
  };
  
  # Vesktop cus discord on wayland is goofy I think
  programs.vesktop = {
    enable = true;
    vencord = {
      themes = {
				custom = "/home/conor/.files/themes/Vesktop/CustomMaterialDiscordFix.theme.css";
      }; # marked as broken
      settings.enabledThemes = [ "custom" ];
      useSystem = true;
    };
  };

  # Fix for UWSM/systemd conflict
  wayland.windowManager.hyprland.systemd.enable = false;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    ".config/gtk-3.0/gtk.css".source = config.lib.file.mkOutOfStoreSymlink /home/conor/.files/themes/adw-colors/adw-solarized/gtk3-dark.css; 
    ".config/gtk-4.0/gtk.css".source = config.lib.file.mkOutOfStoreSymlink /home/conor/.files/themes/adw-colors/adw-solarized/gtk4-dark.css; 
    ".config/vesktop/themes/CustomMaterialDiscord.theme.css".source = config.lib.file.mkOutOfStoreSymlink /home/conor/.files/themes/Vesktop/CustomMaterialDiscord.theme.css;
    ".local/share/applications/Sober.desktop".text = '' # Let me run Sober from wofi
      [Desktop Entry]
      Name=Sober
      Comment=Play Roblox on flatpak
      Exec=flatpak run org.vinegarhq.Sober
      Terminal=false
      Type=Application
      Categories=Game;
    '';
    ".local/share/applications/Doors.desktop".text = '' # Let me run Doors from wofi
      [Desktop Entry]
      Name=Doors
      Comment=Play doors on Roblox
      Type=Application
      Terminal=false
      Exec=firefox roblox://placeId=6516141723/
      Categories=Game;
    '';        
    ".config/discord-rpc/config.toml".text = ''
        [format]
        details = "$title"
        state = "$artist"
        timestamp = "both"
        large_image = "notes"
        small_image = ""
        large_text = "$album"
        small_text = ""
        display_type = "details"
    '';
    ".nanorc".text = ''
      set softwrap
      set tabsize 2
      set zap
      set mouse
      set autoindent
    '';
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
    NIXOS_OZONE_WL = "1"; 
    XCURSOR_SIZE = "24";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
