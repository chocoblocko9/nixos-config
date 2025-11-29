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
    stateVersion = "25.05";
  };

  # The home.packages option allows you to install Nix packages into your environment.
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    firefox
    pavucontrol
    zip
    unzip
    nwg-look   
    fastfetch
    rocmPackages.rocminfo
    rocmPackages.rocm-smi
    jq
    heroic

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

  services.playerctld.enable = true;

  # mpd
  services.mpd = {
    enable = true;
    musicDirectory = "/home/conor/1TB-Hard-Drive/Bandcamp/";
    # Optional:
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

  # rmpc
  programs.rmpc = {
    enable = true;
    config = ''
      #![enable(implicit_some)]
      #![enable(unwrap_newtypes)]
      #![enable(unwrap_variant_newtypes)]
      (
        on_song_change: ["/home/conor/.files/scripts/rmpc/rmpc-notif"],
        tabs: [
        ( name: "Queue",  pane: Split
          ( direction: Horizontal,  panes: 
            [
              ( size: "40%", pane: Pane(AlbumArt)),
              ( size: "60%", pane: Split 
                ( direction: Vertical,  panes: 
                  [
                    ( size: "50%", pane: Pane(Queue)),
                    ( size: "50%", pane: Pane(Cava)),
                  ],
                ),
              ), 
            ],
          ),
        ),
        ( name: "Directories",  pane: Pane(Directories),  ),
        ( name: "Artists",  pane: Pane(Artists),  ),
        ( name: "Album Artists",  pane: Pane(AlbumArtists), ),
        ( name: "Albums", pane: Pane(Albums), ),
        ( name: "Playlists",  pane: Pane(Playlists),  ),
        ( name: "Search", pane: Pane(Search), ),
        ],

        cava: (
          framerate: 60, // default 60
          autosens: true, // default true
          sensitivity: 100, // default 100
          lower_cutoff_freq: 50, // not passed to cava if not provided
          higher_cutoff_freq: 10000, // not passed to cava if not provided
          input: (
            method: Fifo,
            source: "/tmp/mpd.fifo",
            sample_rate: 44100,
            channels: 2,
            sample_bits: 16,
          ),
          smoothing: (
            noise_reduction: 77, // default 77
            monstercat: false, // default false
            waves: true, // default false
          ),  
        ),
      )
    '';
  }; 

  # mpd-discord-rpc
  services.mpd-discord-rpc = {
    enable = true;
    settings = { 
      format = {
        details = "$title";
        state = "$album by $artist";
        timestamp = "both";
        large_image = "notes";
        small_image = "";
        large_text = "";
        small_text = "";
        display_type = "details";
      };
    };
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
      rebuild = "sudo nixos-rebuild switch --flake .";
      ll = "ls -la"; 
      icat = "kitten icat";
      ets2 = "streamlink -p vlc -a \"-vvv - --sout \#transcode{vcodec=none,acodec=mp3,ab=320,scodec=none}:standard{access=http,mux=raw,dst=127.0.0.1:8080}\" --twitch-disable-hosting --twitch-disable-ads https://www.youtube.com/watch?v=edqlOxtnvL0 144p";
    };
  };
  
  # Vesktop + Vencord
  programs.vesktop = {
    enable = true;
    vencord = {
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
    ".local/share/applications/Sober.desktop".text = ''
      [Desktop Entry]
      Name=Sober
      Comment=Play Roblox on flatpak
      Exec=flatpak run org.vinegarhq.Sober
      Terminal=false
      Type=Application
      Categories=Game;
    '';
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/conor/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
    NIXOS_OZONE_WL = "1"; 
    XCURSOR_SIZE = "24";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
