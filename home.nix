{ config, lib, pkgs, pkgs-stable, inputs, ... }:
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
    mprisence
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
    };
  };
  
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # This is probably like a comically bad way of doing this but it works okay!! Custom GTK themes are annoying.
    ".config/gtk-3.0/gtk.css".source = config.lib.file.mkOutOfStoreSymlink /home/conor/.files/themes/adw-colors/adw-solarized/gtk3-dark.css; 
    ".config/gtk-4.0/gtk.css".source = config.lib.file.mkOutOfStoreSymlink /home/conor/.files/themes/adw-colors/adw-solarized/gtk4-dark.css;      
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
    NIXOS_OZONE_WL = "1"; 
    XCURSOR_SIZE = "24";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
