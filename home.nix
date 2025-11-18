{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "conor";
  home.homeDirectory = "/home/conor";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    pkgs.hello
    pkgs.firefox
    pkgs.pavucontrol

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
    };
  };
  
  # Vesktop + Vencord
  programs.vesktop = {
    enable = true;
    vencord = {
      useSystem = true;
    };
  };


  # Hyprland
  programs.kitty.enable = true;
  programs.wofi.enable = true;
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Execute on boot
      "exec-once" = [
        "firefox"
         "discord"
      ];
      
      "input" = {
        "kb_layout" = "de";
        "kb_variant" = "qwerty";
      };

      # Environment Variables
      "env" = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,18"
      ];

      # Set apps
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "Thunar";
      "$menu" = "wofi --show drun";
  
      # Keybinds
      bind = 
        [
          # Standard program binds
          "$mod, F, exec, firefox"
          ", Print, exec, grimblast copy area" 
          "$mod, Q, exec, $terminal"
          "$mod, M, exit,"
          "$mod, C, killactive,"
          "$mod, E, exec, $fileManager"
          "$mod, V, togglefloating,"
          "$mod, D, exec, $menu"
          "$mod, P, pseudo," # dwindle
          "$mod, J, togglesplit," # dwindle
      ];
    };
  };
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

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
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
