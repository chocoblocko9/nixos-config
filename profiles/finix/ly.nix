{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.ly;

  configFile = pkgs.writeText "config.ini" ( lib.generators.toKeyValue {} cfg.settings );

  # Sourced from https://github.com/fairyglade/ly/blob/master/res/setup.sh
  setupScript = ''
    #!/bin/sh
    # Shell environment setup after login
    # Copyright (C) 2015-2016 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>

    # This file is extracted from kde-workspace (kdm/kfrontend/genkdmconf.c)
    # Copyright (C) 2001-2005 Oswald Buddenhagen <ossi@kde.org>

    # Copyright (C) 2024 The Fairy Glade
    # This work is free. You can redistribute it and/or modify it under the
    # terms of the Do What The Fuck You Want To Public License, Version 2,
    # as published by Sam Hocevar. See the LICENSE file for more details.

    # Note that the respective logout scripts are not sourced.
    case $SHELL in
    */bash)
        [ -z "$BASH" ] && exec $SHELL "$0" "$@"
        set +o posix
        [ -f "$CONFIG_DIRECTORY"/profile ] && . "$CONFIG_DIRECTORY"/profile
        if [ -f "$HOME"/.bash_profile ]; then
            . "$HOME"/.bash_profile
        elif [ -f "$HOME"/.bash_login ]; then
            . "$HOME"/.bash_login
        elif [ -f "$HOME"/.profile ]; then
            . "$HOME"/.profile
        fi
        ;;
    */zsh)
        [ -z "$ZSH_NAME" ] && exec $SHELL "$0" "$@"
        [ -d "$CONFIG_DIRECTORY"/zsh ] && zdir="$CONFIG_DIRECTORY"/zsh || zdir="$CONFIG_DIRECTORY"
        zhome=$\{ZDOTDIR:-"$HOME"}
        # zshenv is always sourced automatically.
        [ -f "$zdir"/zprofile ] && . "$zdir"/zprofile
        [ -f "$zhome"/.zprofile ] && . "$zhome"/.zprofile
        [ -f "$zdir"/zlogin ] && . "$zdir"/zlogin
        [ -f "$zhome"/.zlogin ] && . "$zhome"/.zlogin
        emulate -R sh
        ;;
    */csh|*/tcsh)
        # [t]cshrc is always sourced automatically.
        # Note that sourcing csh.login after .cshrc is non-standard.
        sess_tmp=$(mktemp /tmp/sess-env-XXXXXX)
        $SHELL -c "if (-f $CONFIG_DIRECTORY/csh.login) source $CONFIG_DIRECTORY/csh.login; if (-f ~/.login) source ~/.login; /bin/sh -c 'export -p' >! $sess_tmp"
        . "$sess_tmp"
        rm -f "$sess_tmp"
        ;;
    */fish)
        [ -f "$CONFIG_DIRECTORY"/profile ] && . "$CONFIG_DIRECTORY"/profile
        [ -f "$HOME"/.profile ] && . "$HOME"/.profile
        sess_tmp=$(mktemp /tmp/sess-env-XXXXXX)
        $SHELL --login -c "/bin/sh -c 'export -p' > $sess_tmp"
        . "$sess_tmp"
        rm -f "$sess_tmp"
        ;;
    *) # Plain sh, ksh, and anything we do not know.
        [ -f "$CONFIG_DIRECTORY"/profile ] && . "$CONFIG_DIRECTORY"/profile
        [ -f "$HOME"/.profile ] && . "$HOME"/.profile
        ;;
    esac

    if [ "$XDG_SESSION_TYPE" = "x11" ]; then
        [ -f "$CONFIG_DIRECTORY"/xprofile ] && . "$CONFIG_DIRECTORY"/xprofile
        [ -f "$HOME"/.xprofile ] && . "$HOME"/.xprofile

        # run all system xinitrc shell scripts.
        if [ -d "$CONFIG_DIRECTORY"/X11/xinit/xinitrc.d ]; then
            for i in "$CONFIG_DIRECTORY"/X11/xinit/xinitrc.d/* ; do
                if [ -x "$i" ]; then
                    . "$i"
                fi
            done
        fi

        # Load Xsession scripts
        # OPTIONFILE, USERXSESSION, USERXSESSIONRC and ALTUSERXSESSION are required
        # by the scripts to work
        xsessionddir="$CONFIG_DIRECTORY"/X11/Xsession.d
        export OPTIONFILE="$CONFIG_DIRECTORY"/X11/Xsession.options
        export USERXSESSION="$HOME"/.xsession
        export USERXSESSIONRC="$HOME"/.xsessionrc
        export ALTUSERXSESSION="$HOME"/.Xsession

        if [ -d "$xsessionddir" ]; then
            for i in $(ls "$xsessionddir"); do
                script="$xsessionddir/$i"
                echo "Loading X session script $script"
                if [ -r "$script" ] && [ -f "$script" ] && expr "$i" : '^[[:alnum:]_-]\+$' > /dev/null; then
                    . "$script"
                fi
            done
        fi

        if [ -f "$USERXSESSION" ]; then
            . "$USERXSESSION"
        fi

        if [ -d "$CONFIG_DIRECTORY"/X11/Xresources ]; then
            for i in "$CONFIG_DIRECTORY"/X11/Xresources/*; do
                [ -f "$i" ] && xrdb -merge "$i"
            done
        elif [ -f "$CONFIG_DIRECTORY"/X11/Xresources ]; then
            xrdb -merge "$CONFIG_DIRECTORY"/X11/Xresources
        fi
        [ -f "$HOME"/.Xresources ] && xrdb -merge "$HOME"/.Xresources
        [ -f "$XDG_CONFIG_HOME"/X11/Xresources ] && xrdb -merge "$XDG_CONFIG_HOME"/X11/Xresources
    fi

    exec "$@" 
  '';
in
{
  options.services.ly = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable ly as a display manager.";
    };

    package = lib.mkPackageOption pkgs "ly" { };

    settings = lib.mkOption {
      type = with lib.types; attrsOf iniFmt.lib.types.atom;
      default = { };
      description = ''
        ly configuration. See [upstream documentation](https://github.com/fairyglade/ly#configuration)
        for available options.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    services.ly.settings = {
      tty = lib.mkDefault 2;
      path = lib.mkDefault "/run/current-system/sw/bin";
      service_name = lib.mkDefault "ly";
      term_reset_cmd = lib.mkDefault "${pkgs.ncurses}/bin/tput reset";
      term_restore_cursor_cmd = lib.mkDefault "${pkgs.ncurses}/bin/tput cnorm";
      waylandsessions = lib.mkDefault "/run/current-system/sw/share/wayland-sessions";
      xsessions = lib.mkDefault "/run/current-system/sw/share/xsessions";
      setup_cmd = lib.mkDefault "/etc/ly/setup.sh"; 
      # setup_cmd = "exec '$@'";
    };

    environment.etc."ly/config.ini".source = configFile;
    environment.etc."ly/setup.sh".text = setupScript;

    environment.pathsToLink = [ "/share/ly" ];

    environment.systemPackages = [ cfg.package ];

    services.dbus.packages = [ cfg.package ];

    security.pam.services.ly.text = ''
      # Account management.
      account required pam_unix.so
      # Authentication management.
      auth optional pam_unix.so likeauth nullok
      auth sufficient pam_unix.so likeauth nullok try_first_pass
      auth required pam_deny.so
      # Password management.
      password sufficient pam_unix.so nullok yescrypt
      # Session management.
      session required pam_env.so debug conffile=/etc/security/pam_env.conf readenv=1
      session required pam_unix.so
      session optional pam_loginuid.so
      ${lib.optionalString config.services.elogind.enable "session optional ${pkgs.elogind}/lib/security/pam_elogind.so"}
      ${lib.optionalString config.services.seatd.enable "session optional ${pkgs.pam_rundir}/lib/security/pam_rundir.so"}
      session required ${config.security.pam.package}/lib/security/pam_lastlog.so silent
    '';

    # Disable the tty that ly runs on
    finit.ttys."tty${toString cfg.settings.tty}".enable = false;

    finit.services.ly = {
      description = "ly terminal display/login manager";
      runlevels = "34";
      conditions = [
        "service/syslogd/ready"
      ]
      ++ lib.optionals config.services.elogind.enable [ "service/elogind/ready" ]
      ++ lib.optionals config.services.seatd.enable [ "service/seatd/ready" ];
      command = "${pkgs.util-linux}/bin/agetty -nil ${cfg.package}/bin/ly tty${toString cfg.settings.tty}";
      cgroup.name = "user";
    };
  };
}
