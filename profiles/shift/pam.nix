{
  config,
  pkgs,
  lib,
  ...
}:
{
  security.pam.debug = true;

  security.pam.services = lib.mkMerge [
    {
      login.text = lib.mkForce ''
        # Account management.
        account required pam_unix.so # unix (order 10900)

        # Authentication management.
        auth optional pam_unix.so likeauth nullok # unix-early (order 11500)
        auth sufficient pam_unix.so likeauth nullok try_first_pass # unix (order 12800)
        auth required pam_deny.so # deny (order 13600)

        # Password management.
        password sufficient pam_unix.so nullok yescrypt # unix (order 10200)

        # Session management.
        session required pam_env.so conffile=/etc/security/pam_env.conf readenv=0 # env (order 10100)
        session required pam_unix.so # unix (order 10200)
        session required pam_loginuid.so # loginuid (order 10300)
        session required ${config.security.pam.package}/lib/security/pam_lastlog.so silent # lastlog (order 10700)

        ${lib.optionalString config.services.elogind.enable "session optional ${pkgs.elogind}/lib/security/pam_elogind.so"}
        ${lib.optionalString config.services.seatd.enable "session optional ${pkgs.pam_xdg}/lib/security/pam_xdg.so runtime track_sessions"}
      '';

      ly.text = lib.mkForce ''
        # Account management.
        account required pam_unix.so

        # Authentication management.
        auth required pam_unix.so likeauth nullok
        auth optional ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so

        # Password management.
        password sufficient pam_unix.so nullok yescrypt

        # Session management.
        session required pam_env.so conffile=/etc/security/pam_env.conf readenv=0
        session required pam_unix.so
        session required pam_loginuid.so
        session required pam_limits.so conf=/etc/security/limits.conf debug # limits (order 10400) - needed for rtprio/realtime audio
        session optional ${pkgs.pam_xdg}/lib/security/pam_xdg.so runtime track_sessions
        session optional ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start

        ${lib.optionalString config.services.elogind.enable "session optional ${pkgs.elogind}/lib/security/pam_elogind.so"}
        ${lib.optionalString config.services.seatd.enable "session optional ${pkgs.pam_xdg}/lib/security/pam_xdg.so runtime track_sessions"}
      '';
    }

    (lib.mkIf config.programs.doas.enable or false {
      doas.text = lib.mkForce ''
        # Account management.
        account required pam_unix.so # unix (order 10900)

        # Authentication management.
        auth sufficient pam_unix.so likeauth nullok try_first_pass # unix (order 11500)
        auth required pam_deny.so # deny (order 12300)

        # Password management.
        password sufficient pam_unix.so nullok yescrypt # unix (order 10200)

        # Session management.
        session required pam_env.so conffile=/etc/security/pam_env.conf readenv=0 # env (order 10100)
        session required pam_unix.so # unix (order 10200)
        session required pam_limits.so conf=/etc/security/limits.conf debug # limits (order 10400) - needed for rtprio/realtime
      '';
    })

    (lib.mkIf config.programs.sudo.enable or false {
      sudo.text = lib.mkForce ''
        # Account management.
        account required pam_unix.so # unix (order 10900)

        # Authentication management.
        auth sufficient pam_unix.so likeauth try_first_pass # unix (order 11500)
        auth required pam_deny.so # deny (order 12300)

        # Password management.
        password sufficient pam_unix.so nullok yescrypt # unix (order 10200)

        # Session management.
        session required pam_env.so conffile=/etc/security/pam_env.conf readenv=0 # env (order 10100)
        session required pam_unix.so # unix (order 10200)
        session required pam_limits.so conf=/etc/security/limits.conf debug # limits (order 10400) - needed for rtprio/realtime
      '';
    })

    (lib.mkIf config.programs.hyprlock.enable or false {
      hyprlock.text = lib.mkForce ''
        # Account management.
        account required pam_unix.so # unix (order 10900)

        # Authentication management.
        auth sufficient pam_unix.so likeauth try_first_pass # unix (order 11500)
        auth required pam_deny.so # deny (order 12300)

        # Password management.
        password sufficient pam_unix.so nullok yescrypt # unix (order 10200)

        # Session management.
        session required pam_env.so conffile=/etc/security/pam_env.conf readenv=0 # env (order 10100)
        session required pam_unix.so # unix (order 10200)
        session required pam_limits.so conf=/etc/security/limits.conf debug # limits (order 10400) - needed for rtprio/realtime
      '';
    })

    (lib.mkIf config.services.greetd.enable or false {
      greetd.text = lib.mkForce ''
        # Account management.
        account required pam_unix.so # unix (order 10900)

        # Authentication management.
        auth optional pam_unix.so likeauth nullok # unix-early (order 11500)
        auth sufficient pam_unix.so likeauth nullok try_first_pass # unix (order 12800)
        auth required pam_deny.so # deny (order 13600)

        # Password management.
        password sufficient pam_unix.so nullok yescrypt # unix (order 10200)

        # Session management.
        session required pam_env.so debug conffile=/etc/security/pam_env.conf readenv=1 # env (order 10100)
        session required pam_unix.so # unix (order 10200)
        # https://github.com/coastalwhite/lemurs/issues/166
        # session optional pam_loginuid.so # loginuid (order 10300)
        session required pam_limits.so conf=/etc/security/limits.conf debug # limits (order 10400) - needed for rtprio/realtime audio

        ${lib.optionalString config.services.elogind.enable "session optional ${pkgs.elogind}/lib/security/pam_elogind.so"}
        ${lib.optionalString config.services.seatd.enable "session optional ${pkgs.pam_xdg}/lib/security/pam_xdg.so runtime track_sessions"}

        session required ${pkgs.linux-pam}/lib/security/pam_lastlog.so silent # lastlog (order 10700)
      '';
    })
  ];
}

