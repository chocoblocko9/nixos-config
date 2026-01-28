{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    ./hypr/hyprland.nix
    ./hypr/hyprpaper.nix
    ./hypr/hyprsunset.nix
  ];
  
  # Home Manager needs a bit of information about you and the paths it should manage.
  home = {
   	username = "conor";
   	homeDirectory = "/home/conor";
 	  stateVersion = "25.11";
	 };

	stylix = {
		enable = false;
		base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
	};
		
	programs.nixcord = {
		enable = true;
		vesktop.enable = true;
		config = {
			themeLinks = [ https://raw.githubusercontent.com/chocoblocko9/Material-Discord-Cyan/refs/heads/master/Material-Discord.theme.css ];

		plugins = {
				fakeNitro.enable = true;
				fixSpotifyEmbeds = {
					enable = true;
					volume = 5.0;
				};
				fixYoutubeEmbeds.enable = true;
				implicitRelationships.enable = true;
				memberCount.enable = true;
				mentionAvatars.enable = true;
				moreQuickReactions = {
					enable = true;
					reactionCount = 6;
				};
				noUnblockToJump.enable = true;
				platformIndicators = {
					enable = true;
					consoleIcon = "vencord";
				};
				previewMessage.enable = true;
				replyTimestamp.enable = true;
				serverInfo.enable = true;
				translate.enable = true;
				shikiCodeblocks.enable = true;
				volumeBooster.enable = true;
				webScreenShareFixes.enable = true;
				whoReacted.enable = true;
				youtubeAdblock.enable = true;
			};
		};
	};


	
  
  # The home.packages option allows you to install Nix packages into your environment.
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    # Programs
    firefox
    heroic # Good games launcher
    cemu # Wii U my beloved
    prismlauncher
   # parallel-launcher
    python315
    nicotine-plus # Soulseek
    jdk21_headless
    vlc
    lollypop
   

    # Tools
    pavucontrol
    fastfetch
    zip
    unzip
    nwg-look # GTK themes manager
    jq # hyprland minimise script needs this or smth
    feh # GUI image viewer
    xarchiver # GUI archive manager
		libsForQt5.qt5ct
		puddletag # song file tagger
    streamlink 
    ncdu 
    wev 
    unipicker
    mprisence
	
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
  	rescrobbled = {
  		enable = false;
  		settings = {
  			#filter-script = "path/to/script";
				lastfm-key = "${config.home.sessionVariables.LASTFM_KEY}";
  		  lastfm-secret = "${config.home.sessionVariables.LASTFM_SECRET}";
			  #min-play-time = 0;
  			player-whitelist = [ "Lollypop" ];
  			use-track-start-timestamp = true;
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

  # Vesktop cus discord on wayland is goofy I think
  #programs.vesktop.enable = true;

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

  home.file = {
    ".config/gtk-3.0/gtk.css".source = config.lib.file.mkOutOfStoreSymlink /home/conor/.files/themes/adw-colors/adw-solarized/gtk3-dark.css; 
    ".config/gtk-4.0/gtk.css".source = config.lib.file.mkOutOfStoreSymlink /home/conor/.files/themes/adw-colors/adw-solarized/gtk4-dark.css; 
    ".local/share/applications/Doors.desktop".text = '' # Let me run Doors from wofi
      [Desktop Entry]
      Name=Doors
      Comment=Play doors on Roblox
      Type=Application
      Terminal=false
      Exec=firefox --new-window roblox://placeId=6516141723/
      Categories=Game;
    '';        
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1"; 
    XCURSOR_SIZE   = "24";
    LASTFM_KEY     = ~/Documents/lastfmkey; # horrible horrible bad bad dont do this 
    LASTFM_SECRET  = ~/Documents/lastfmsecret; # WHY DOES AGENIX NOT WORK???
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
