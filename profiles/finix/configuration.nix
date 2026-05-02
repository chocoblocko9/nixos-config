{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  pipewire' =
    (pkgs.pipewire.override (
      lib.optionalAttrs config.services.mdevd.enable {
        enableSystemd = false;
        udev = pkgs.libudev-zero;
      }
    )).overrideAttrs
      (o: {
        # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/2398#note_2967898
        patches = o.patches or [ ] ++ lib.optionals config.services.mdevd.enable [ ./pipewire.patch ];
      });

  wireplumber' = pkgs.wireplumber.override (
    lib.optionalAttrs config.services.mdevd.enable {
      pipewire = pipewire';
    }
  );

  seatd' = pkgs.seatd.override { systemdSupport = false; };

  xdg-desktop-portal' = pkgs.xdg-desktop-portal.override { enableSystemd = false; };

  ly' = pkgs.ly.overrideAttrs (oldAttrs: {
    version = "1.4.0";
    src = pkgs.fetchFromGitea {
      domain = "codeberg.org";
      owner = "fairyglade";
      repo = "ly";
      tag = "v1.4.0";
      hash = "sha256-8wAt0gpIV97GY17B6rhjnhVR/UuuGQSAaKOcr+G1mKo=";
    };
  });

  libinput = pkgs.libinput.override (
    lib.optionalAttrs config.services.mdevd.enable {
      udev = pkgs.libudev-zero;
      wacomSupport = false;
    }
  );

  aquamarine = pkgs.aquamarine.override (
    lib.optionalAttrs config.services.mdevd.enable {
      inherit libinput;

      udev = pkgs.libudev-zero;
    }
  );

  hyprland' = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.override {
    inherit aquamarine libinput;
    withSystemd = false;
  };

  xdph' = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland.override {
    hyprland = hyprland';
  };
in
{
  imports = [
    ./hardware-configuration.nix
    ./pam.nix
    ./zsh.nix
    ./flatpak.nix
    ./steam.nix

    ../../profiles/slip/hjem.nix 
  ];

  hjem.users.conor = {
    directory = "/home/conor";
    environment.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  specialisation.udev = {
    services.mdevd.enable = lib.mkForce false;
    services.udev.enable = lib.mkForce true;
  };

  boot.loader.efi.canTouchEfiVariables = true;

  programs.limine.enable = true;
  programs.limine.settings.editor_enabled = true;

  services.elogind.package = pkgs.elogind;

  security.pam.environment = {
    EDITOR.override = "nvim";

    # https://wiki.nixos.org/wiki/Accelerated_Video_Playback#Intel
    LIBVA_DRIVER_NAME.default = "iHD";
  };

  # TODO: some sort of option i guess
  environment.etc."security/limits.conf".text = ''
    @audio   -   rtprio     95
    @audio   -   nice       -19
    @audio   -   memlock    4194304
  '';

  time.timeZone = "Europe/Dublin";

  boot.supportedFilesystems = {
    btrfs.enable = true;
    ntfs3.enable = true;
    ext4.enable = true;
  };

  boot.kernelParams = [
    "loglevel=1"

    # https://community.frame.work/t/linux-battery-life-tuning/6665/156
    "nvme.noacpi=1"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  programs.steam.enable = false;

  fileSystems = {
    "/home/conor/2TB-Hard-Drive" = {
      device = "/dev/disk/by-uuid/203EA3F63EA3C2E0";
      fsType = "ntfs3";
      options = [ 
        "users" 
        "nofail" 
        "exec" 
        "uid=1000"
        "gid=100"
        "dmask=022"
        "fmask=133"
      ];
    };

    "/home/conor/1TB-Hard-Drive" = {
      device = "/dev/disk/by-uuid/98046F01046EE22C";
      fsType = "ntfs3";
      options = [ 
        "users" 
        "nofail" 
        "exec" 
        "uid=1000"
        "gid=100"
        "dmask=022"
        "fmask=133"
      ];
    };
  };

  finit.services.nix-daemon.environment.CURL_CA_BUNDLE = config.security.pki.caBundle;
  finit.services.nix-daemon.path = [
    config.services.nix-daemon.package
    pkgs.util-linux
    config.services.openssh.package
  ];

  networking.hostName = "subvert";

  finit.runlevel = 3;

  services.chrony.enable = true;
  services.dbus.enable = true;
  services.flatpak.enable = true;
  services.dhcpcd.enable = true;
  services.iwd.enable = true;
  services.nix-daemon.enable = true;
  services.nix-daemon.package = pkgs.lix;
  services.nix-daemon.settings = {
    # Hyprland Cachix
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];

    max-jobs = 1;
    cores = 12;

    # Flakes 
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    build-dir = "/nix/tmp";

    trusted-users = [
      "root"
      "@wheel"
    ];
  };
  services.openssh.enable = false;
  services.sysklogd.enable = true;
  services.mdevd.enable = true;
  services.mdevd.nlgroups = 4;
  services.mdevd.debug = true;

  # .* 0:0 660 @${pkgs.finit}/libexec/finit/logit -s -t mdevd "event=$ACTION dev=$MDEV subsystem=$SUBSYSTEM path=$DEVPATH devtype=$DEVTYPE modalias=$MODALIAS major=$MAJOR minor=$MINOR"
  # TODO: shouldn't this just be included by default?
  services.mdevd.hotplugRules = lib.mkMerge [
    (lib.mkAfter ''
      SUBSYSTEM=input;.* root:input 660
      SUBSYSTEM=sound;.* root:audio 660
    '')

    ''
      grsec       root:root 660
      kmem        root:root 640
      mem         root:root 640
      port        root:root 640
      console     root:tty 600 @chmod 600 $MDEV
      card[0-9]   root:video 660 =dri/

      # alsa sound devices and audio stuff
      pcm.*       root:audio 0660 =snd/
      control.*   root:audio 0660 =snd/
      midi.*      root:audio 0660 =snd/
      seq         root:audio 0660 =snd/
      timer       root:audio 0660 =snd/

      adsp        root:audio 0660 >sound/
      audio       root:audio 0660 >sound/
      dsp         root:audio 0660 >sound/
      mixer       root:audio 0660 >sound/
      sequencer.* root:audio 0660 >sound/

      event[0-9]+ root:input 660 =input/
      mice        root:input 660 =input/
      mouse[0-9]+ root:input 660 =input/

      rfkill      root:${config.services.seatd.group} 660
    ''
  ];
  services.nftables.enable = true;
  services.nftables.configFile = pkgs.writeText "nftables.conf" ''
    # https://wiki.nftables.org/wiki-nftables/index.php/Quick_reference-nftables_in_10_minutes#Simple_IP/IPv6_Firewall

    flush ruleset

    table firewall {
      chain incoming {
        type filter hook input priority 0; policy drop;

        # established/related connections
        ct state established,related accept

        # loopback interface
        iifname lo accept

        # icmp
        icmp type echo-request accept

        # open tcp ports: sshd (22), http-alt (8080)
        tcp dport { 22, 8080 } accept
      }
    }

    table ip6 firewall {
      chain incoming {
        type filter hook input priority 0; policy drop;

        # established/related connections
        ct state established,related accept

        # invalid connections
        ct state invalid drop

        # loopback interface
        iifname lo accept

        # icmp
        # routers may also want: mld-listener-query, nd-router-solicit
        icmpv6 type { echo-request, nd-neighbor-solicit } accept

        # open tcp ports: sshd (22), http-alt (8080)
        tcp dport { 22, 8080 } accept
      }
    }
  '';
  services.polkit.enable = true;

  programs.resolvconf.enable = true;
  programs.resolvconf.package = pkgs.openresolv.overrideAttrs (_: {
    # TODO: could potentially make 'RESTARTCMD' an overridable option for the package
    configurePhase = ''
      cat > config.mk <<EOF
      PREFIX=$out
      SYSCONFDIR=/etc
      SBINDIR=$out/sbin
      LIBEXECDIR=$out/libexec/resolvconf
      VARDIR=/run/resolvconf
      MANDIR=$out/share/man
      RESTARTCMD="/run/current-system/sw/bin/initctl restart \\\\\$\$1"
      EOF
    '';
  });
  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.sudo.enable = true;
  programs.gnome-keyring.enable = true;

  services.rtkit.enable = true;
  services.bluetooth.enable = true;
  services.seatd.enable = true;
  finit.services.seatd.command = lib.mkForce "${seatd'.bin}/bin/seatd -n %n -u root -g ${config.services.seatd.group}";
  programs.regreet.enable = false;
  services.ly = {
    enable = true;
    package = ly';
    settings = {
      show_tty = true;
      allow_empty_password = true;
      auth_fails = 8;
      default_input = "login";
      full_color = true;
      save = true;
      shutdown_key = "F1";
      restart_key = "F2";
      sleep_key = "F3";
      sleep_cmd = "suspend";
      brightness_down_key = "F5";
      brightness_up_key = "F6";
      brightness_down_cmd = "${pkgs.ddcutil}/bin/ddcutil --sleep-multiplier .1 --bus=5 setvcp 10 - 10";
      brightness_up_cmd = "${pkgs.ddcutil}/bin/ddcutil --sleep-multiplier .1 --bus=5 setvcp 10 + 10";
      animation = "colormix";
      colormix_col1 = "0x20000000";
      colormix_col2 = "0x01009494";
      colormix_col3 = "0x01000080";
      asterisk = ">";
      bg = "0x20000000";
      clock = "%H:%M:%S %a, %d/%m/%Y";
      bigclock = "en";
      bigclock_seconds = true;
      bigclock_12hr = false;
    };
  };

  services.xserver.enable = true; 

  finit.cgroups = {
    system.settings."cpu.weight" = 100;
    user.settings."cpu.weight" = 100;
  };

  # misc
  services.vnstat.enable = true;
  services.upower.enable = true;
  services.zerotierone.enable = true;

  # NOTE: https://wiki.alpinelinux.org/wiki/Polkit#Using_polkit_with_seatd
  services.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("org.freedesktop.Flatpak.") == 0 && subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }

      if (subject.isInGroup("${config.services.seatd.group}") && action.id.startsWith("org.freedesktop.RealtimeKit1.")) {
        return polkit.Result.YES;
      }

      if (subject.isInGroup("${config.services.seatd.group}") && action.id.startsWith("org.freedesktop.UPower.PowerProfiles.")) {
        return polkit.Result.YES;
      }
    });
  '';

  xdg.portal.portals = [ 
    xdph'
    xdg-desktop-portal'
  ];

  services.dbus.packages = [
    pkgs.dconf
  ];

  fonts.fontconfig.enable = true;

  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts._0xproto
    noto-fonts
    noto-fonts-color-emoji
  ];

  # TODO: move to services.sysklogd module
  environment.etc."syslog.d/rotate.conf".text = ''
    rotate_size  1M
    rotate_count 5
  '';

  providers.privileges.rules = [
    {
      command = "/run/current-system/sw/bin/poweroff";
      users = [ "conor" ];
      requirePassword = false;
    }
    {
      command = "/run/current-system/sw/bin/reboot";
      users = [ "conor" ]; requirePassword = false; }
  ]
  ++ lib.optionals config.services.mdevd.enable [
    {
      command = "/run/current-system/sw/bin/pm-suspend";
      groups = [ config.services.seatd.group ];
      requirePassword = false;
    }
    {
      command = "/run/current-system/sw/bin/zzz";
      groups = [ config.services.seatd.group ];
      requirePassword = false;
    }
    {
      command = "/run/current-system/sw/bin/ZZZ";
      groups = [ config.services.seatd.group ];
      requirePassword = false;
    }
  ];

  services.udev.packages = [
    config.services.udev.package
  ];

  hardware.firmware = with pkgs; [
    linux-firmware
    sof-firmware
    wireless-regdb
  ];

  users.users.root.password = "$6$7luPjbNjbmrf1rvj$RAWwzn//WtL3PTm6LRjYqus1ELrAzXagWdmvroHVbPMP8.3Ze0.bzlQN4cRvGTgIfNlKQux6b0Yr2zn.ZvjZa.";

  users.users.conor = {
    isNormalUser = true;
    shell = pkgs.zsh;
    group = "users";
    home = "/home/conor";
    createHome = true;
    password = "$6$iipImd5J/ti9RTTW$v.J06z5BoebyBfZ2JSZRjNE8f6HQTPTemuxhHtSq0d6v/SyC1Ghn5Qem7EBkgRQnlpww27Nw7j0SnlbTT81YW.";

    extraGroups = [
      config.hardware.i2c.group
      config.services.seatd.group
      "audio"
      "incus-admin"
      "input"
      "kvm"
      "vboxusers"
      "video"
      "wheel"
      "flatpak"
    ];
  };

  environment.etc.subuid.mode = "0444";
  environment.etc.subgid.mode = "0444";

  environment.etc.subuid.text = "conor:100000:65536";
  environment.etc.subgid.text = "conor:100000:65536";

  users.users.test = {
    isNormalUser = true;
    shell = pkgs.fish;
    group = "users";
    home = "/home/test";
    createHome = true;

    extraGroups = [
      config.hardware.i2c.group
      config.services.seatd.group
      "audio"
      "input"
      "video"
      "wheel"
    ];
  };

  environment.pathsToLink = [
    # TODO: xdg.icon module
    "/share/icons"
    "/share/pixmaps"
    "/share/X11"
  ];

  environment.systemPackages = [
    pkgs.slurp
    pkgs.grim
    pkgs.wl-clipboard
    pkgs.wf-recorder
    pkgs.neovim
    pkgs.fastfetch
    pkgs.nixos-rebuild-ng
    pkgs.hyprpaper
    pkgs.hyprsunset
    pkgs.fuzzel

    # Can't use module because it dupes
    hyprland'
    (lib.hiPrio (pkgs.writeTextDir "share/wayland-sessions/hyprland.desktop" ''
      [Desktop Entry]
      Name=Hyprland
      Comment=An intelligent dynamic tiling Wayland compositor
      Exec=${pkgs.dbus}/bin/dbus-run-session -- ${lib.getExe hyprland'}
      Type=Application
      DesktopNames=Hyprland
      Keywords=tiling;wayland;compositor;
    ''))
    
    pkgs.cava
    pkgs.xwayland

    pkgs.ddcutil
    pkgs.kitty
    pkgs.kanshi
    pkgs.musikcube

    pkgs.oxwm
    pkgs.alacritty

    pkgs.adw-gtk3
    pkgs.numix-icon-theme
    pkgs.adwaita-icon-theme

    pkgs.mailutils
    pkgs.man
    pkgs.nano
    # (most of) these tools can/should be moved into a local profile - but kept in sync with <nixpkgs> ideally
    pkgs.vim
    pkgs.delta
    pkgs.direnv
    pkgs.dnsutils
    pkgs.git
    pkgs.btop
    pkgs.nix-prefetch-git
    pkgs.ncdu
    pkgs.nix-diff
    pkgs.nix-output-monitor
    pkgs.nix-top
    pkgs.nix-tree
    pkgs.nixd
    pkgs.ssh-to-age
    pkgs.tree
    pkgs.wget

    pkgs.firefox
    pkgs.qbittorrent
    pkgs.gamescope
    pkgs.xarchiver
    pkgs.nh

    pkgs.libnotify
    pkgs.wiremix
    pipewire'
    pkgs.pavucontrol
    
    wireplumber'
    pkgs.wl-clipboard

    pkgs.iproute2
    pkgs.iputils
    pkgs.nettools

    pkgs.bustle
    pkgs.d-spy
    pkgs.dconf-editor

    pkgs.perl
    pkgs.strace

    pkgs.dconf

    pkgs.util-linux
    pkgs.e2fsprogs
    pkgs.kbd

    pkgs.imv # TODO: set as default image viewer

    # TODO: add `programs.ssh.*` options
    pkgs.openssh
  ];

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
}
