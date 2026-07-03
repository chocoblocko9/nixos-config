{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  ly' = pkgs.callPackage ./ly/package.nix {};

  pipewire' =
    (pkgs.pipewire.override (
      lib.optionalAttrs config.services.mdevd.enable {
        enableSystemd = false;
        udev = libudev-garden;
      }
    )).overrideAttrs
      (o: {
        # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/2398#note_2967898
        patches = o.patches or [ ] ++ lib.optionals (config.services.mdevd.enable || config.services.gardendevd.enable) [ ./pipewire.patch ];
      });

  wireplumber' = pkgs.wireplumber.override (
    lib.optionalAttrs config.services.mdevd.enable {
      pipewire = pipewire';
    }
  );

  seatd' = pkgs.seatd.override { systemdSupport = false; };

  xdg-desktop-portal' = (pkgs.xdg-desktop-portal.override { enableSystemd = false; 
    }).overrideAttrs 
      (o: {
        doCheck = false;
      }
    );

  gardendevd = pkgs.callPackage ./gardendevd.nix {};
  libudev-garden = pkgs.callPackage ./libudev-garden.nix {};

  libinput = pkgs.libinput.override (
    lib.optionalAttrs (config.services.mdevd.enable || config.services.gardendevd.enable) {
      udev = libudev-garden;
      wacomSupport = false;
    }
  );

  aquamarine = pkgs.aquamarine.override (
    lib.optionalAttrs (config.services.mdevd.enable || config.services.gardendevd.enable) {
      inherit libinput;

      udev = libudev-garden;
    }

    /*
    lib.optionalAttrs config.services.keventd.enable {
      inherit libinput;

      udev = pkgs.libudev-zero;
    }
    */
  );

  hyprland = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.override {
    inherit aquamarine libinput;
    withSystemd = false;
  };

  xdph = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland.override {
    inherit hyprland;
  };

  vnstat' = pkgs.callPackage ../../modules/derivations/vnstat/package.nix {};
in
{
  imports = [
    ./hardware-configuration.nix
    ./pam.nix
    ./zsh.nix
    ./flatpak.nix
    ./direnv.nix
     ./openrgb.nix
    inputs.modular-services.nixosModules.default

    ../../profiles/slip/hjem.nix 
  ];


  hjem.users.conor = {
    directory = "/home/conor";
    environment.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  specialisation.gardendevd = {
    services.mdevd.enable = lib.mkForce false;
    #services.seatd.enable = lib.mkForce false;
    #services.elogind.enable = lib.mkForce true;
    environment.etc."specialisation".text = "gardendevd";
  };

  /*
  specialisation.udev = {
    services.mdevd.enable = lib.mkForce false;
    services.gardendevd.enable = lib.mkForce false;
    services.udev.enable = lib.mkForce true;
    environment.etc."specialisation".text = "udev";
  };
  */

  boot.loader.efi.canTouchEfiVariables = true;

  programs.limine.enable = true;
  /*
  programs.limine.package = pkgs.limine.overrideAttrs {
    version = "11.4.1";
    src = pkgs.fetchurl {
      url = "https://github.com/Limine-Bootloader/Limine/releases/download/v11.4.1/limine-11.4.1.tar.gz";
      hash = "sha256-sTmjVVhOb2EOhohW/SMJgrM8HT5t6afq1ekv+6eZNuY=";
    };
  };
  */
  programs.limine.settings = {
    editor_enabled = true;
    wallpaper = [
      ./finix-limine12-bg.png
      # pkgs.nixos-artwork.wallpapers.simple-dark-gray-bootloader.gnomeFilePath
    ];
    wallpaper_style = "centered";
    term_background = "90000000";
    term_background_bright = "90000000";
    term_shadow = "90000000";
    term_margin = "0";
    interface_resolution = "1920x1080";
    interface_help_colour = "e43949";
    interface_branding = "Welcome to finix!";
  };

  services.elogind.package = pkgs.elogind;
  services.hardware.openrgb.enable = true;

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
    conor hard nofile 524288
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
  services.nix-daemon.package = pkgs.nix;
  services.nix-daemon.nrBuildUsers = 32;
  services.nix-daemon.settings = {
    experimental-features = [
      "nix-command"
      "pipe-operators"
      "flakes"
    ];

    system-features = [ 
      "kvm"
      "big-parallel"
      "nixos-test"
      "benchmark"
      "gccarch-native"
    ];

    download-buffer-size = 524288000;
    fallback = true;
    log-lines = 25;
    warn-dirty = false;
    builders-use-substitutes = true;
    build-dir = "/nix/tmp";

    trusted-users = [
      "root"
      "@wheel"
    ];
  };
   
  services.openssh.enable = false;
  services.sysklogd.enable = true;
  services.mdevd.enable = true;
  services.mdevd.nlgroups = 2;
  services.mdevd.debug = true;

  programs.direnv.enable = true;
  programs.direnv.settings = {
    global = {
      hide_env_diff = true;
      log_format = lib.mkDefault "-";
      log_filter = lib.mkDefault "^$";
    };
  };

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

  system.services."meow" = {
    imports = [ pkgs.vnstat.services.default ];

    vnstat = {
      debug = true;
      settings = {

          "CheckDiskSpace" = "1";
          "DatabaseDir" = "/var/lib/vnstat";
      };
    };
  };

  /*
  system.services."meow2" = {
    imports = [ pkgs.ktls-utils.services.default ];

    tlshd.settings = {  
      "loglevel" = "1";
      "authenticate.server" = {
        "x509.certificate" = "/var/lib/tlshd/cert.pem";
        "x509.private_key" = "/var/lib/tlshd/key.pem";
        "x509.truststore" = "/var/lib/tlshd/truststore.pem";
      };
    };

    vnstat = {
      debug = true;
      settings = {
        CheckDiskSpace = "1";
        DatabaseDir = "/var/lib/vnstat";
      };
    };
  };
  */

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

  services.gardendevd.enable = true;
  services.gardendevd.debug = true;
  /*
  finit.services.gardendevd = {
    description = "hi";
    conditions = "service/syslogd/ready";
    command = "${gardendevd}/bin/gardendevd -K -v debug";
  };
  */

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

  finit.cgroups = {
    system.settings."cpu.weight" = 100;
    user.settings."cpu.weight" = 100;
  };

  # misc
  /*
  services.vnstat.enable = true;
  services.vnstat.package = pkgs.vnstat;
  */

  services.upower.enable = true;

  # NOTE: https://wiki.alpinelinux.org/wiki/Polkit#Using_polkit_with_seatd
  services.polkit.extraConfig = ''
      var YES = polkit.Result.YES;
      var permission = {
        // required for udisks1:
        "org.freedesktop.udisks.filesystem-mount": YES,
        "org.freedesktop.udisks.luks-unlock": YES,
        "org.freedesktop.udisks.drive-eject": YES,
        "org.freedesktop.udisks.drive-detach": YES,
        // required for udisks2:
        "org.freedesktop.udisks2.filesystem-mount": YES,
        "org.freedesktop.udisks2.encrypted-unlock": YES,
        "org.freedesktop.udisks2.eject-media": YES,
        "org.freedesktop.udisks2.power-off-drive": YES,
        // required for udisks2 if using udiskie from another seat (e.g. systemd):
        "org.freedesktop.udisks2.filesystem-mount-other-seat": YES,
        "org.freedesktop.udisks2.filesystem-unmount-others": YES,
        "org.freedesktop.udisks2.encrypted-unlock-other-seat": YES,
        "org.freedesktop.udisks2.encrypted-unlock-system": YES,
        "org.freedesktop.udisks2.eject-media-other-seat": YES,
        "org.freedesktop.udisks2.power-off-drive-other-seat": YES
      };

      if (subject.isInGroup("storage")) {
        return permission[action.id];
      }
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

  /*
var YES = polkit.Result.YES;
      var permission = {
        // required for udisks1:
        "org.freedesktop.udisks.filesystem-mount": YES,
        "org.freedesktop.udisks.luks-unlock": YES,
        "org.freedesktop.udisks.drive-eject": YES,
        "org.freedesktop.udisks.drive-detach": YES,
        // required for udisks2:
        "org.freedesktop.udisks2.filesystem-mount": YES,
        "org.freedesktop.udisks2.encrypted-unlock": YES,
        "org.freedesktop.udisks2.eject-media": YES,
        "org.freedesktop.udisks2.power-off-drive": YES,
        // required for udisks2 if using udiskie from another seat (e.g. systemd):
        "org.freedesktop.udisks2.filesystem-mount-other-seat": YES,
        "org.freedesktop.udisks2.filesystem-unmount-others": YES,
        "org.freedesktop.udisks2.encrypted-unlock-other-seat": YES,
        "org.freedesktop.udisks2.encrypted-unlock-system": YES,
        "org.freedesktop.udisks2.eject-media-other-seat": YES,
        "org.freedesktop.udisks2.power-off-drive-other-seat": YES
      };

      if (subject.isInGroup("storage")) {
        return permission[action.id];
      }
      */
    xdg = {
      mime.enable = true;
      portal = {
        enable = true;
        portals = [ 
          xdph
          xdg-desktop-portal'
        ];
      };
    };


  services.dbus.packages = [
    pkgs.dconf
    pkgs.udisks
 ];

  fonts.fontconfig.enable = true;

  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    vegur
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
      command = "/run/current-system/sw/bin/suspend";
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
    pkgs.finit
  ];

  hardware.firmware = with pkgs; [
    linux-firmware
    sof-firmware
    wireless-regdb
  ];

  # users.users.root.password = "$6$7luPjbNjbmrf1rvj$RAWwzn//WtL3PTm6LRjYqus1ELrAzXagWdmvroHVbPMP8.3Ze0.bzlQN4cRvGTgIfNlKQux6b0Yr2zn.ZvjZa.";
  users.users.root.password = "$y$j9T$LpPKMPAMtI3uwzInIeJP0.$dKBJ/eMwaHOo.M154IrvjhhtRFNs9yvDgew0jLvs7NC";

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
      "storage"
      "wheel"
      "flatpak"
    ];
  };

  environment.etc.subuid.mode = "0444";
  environment.etc.subgid.mode = "0444";

  environment.etc.subuid.text = "conor:100000:65536";
  environment.etc.subgid.text = "conor:100000:65536";

  #programs.virtualbox.enable = true;
  programs.virtualbox.package = pkgs.virtualboxWithExtpack;

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

  # services.xserver.enable = true;

  environment.pathsToLink = [
    # TODO: xdg.icon module
    "/share/icons"
    "/share/pixmaps"
    "/share/X11"
    "/share/hypr"
  ];

  environment.systemPackages = [
    pkgs.slurp
    pkgs.grim
    pkgs.wl-clipboard
    pkgs.wf-recorder
    pkgs.neovim
    pkgs.nixos-rebuild-ng
    pkgs.hyprpaper
    pkgs.hyprsunset
    pkgs.fuzzel

    # Can't use module because it dupes
    hyprland

    # inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland
    (lib.hiPrio (pkgs.writeTextDir "share/wayland-sessions/hyprland.desktop" ''
      [Desktop Entry]
      Name=Hyprland
      Comment=An intelligent dynamic tiling Wayland compositor
      Exec=${pkgs.dbus}/bin/dbus-run-session -- ${lib.getExe hyprland}
      Type=Application
      DesktopNames=Hyprland
      Keywords=tiling;wayland;compositor;
    ''))
    
    pkgs.cava
    pkgs.xwayland

    pkgs.ddcutil
    pkgs.kanshi
    pkgs.musikcube

    pkgs.oxwm
    pkgs.alacritty
    pkgs.xinit

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
    pkgs.nix-prefetch-git
    pkgs.ncdu
    pkgs.nix-diff
    pkgs.nix-output-monitor
    pkgs.nix-top
    pkgs.nix-tree
    pkgs.nixd

    pkgs.firefox
    pkgs.qbittorrent
    pkgs.gamescope
    pkgs.xarchiver
    pkgs.nh

    pkgs.libnotify
    pipewire'
    pkgs.pavucontrol
    
    wireplumber'
    pkgs.wl-clipboard

    pkgs.iproute2

    gardendevd

    # qt
    pkgs.libsForQt5.qt5ct
    pkgs.qt6Packages.qt6ct

    pkgs.libsForQt5.qtstyleplugin-kvantum
    pkgs.qt6Packages.qtstyleplugin-kvantum

    pkgs.udiskie
    pkgs.udisks
    pkgs.util-linux
    pkgs.e2fsprogs
    pkgs.kbd
    pkgs.xdg-utils

    pkgs.steam
    pkgs.steam.run
    pkgs.pulseaudio

    pkgs.busybox
    pkgs.imv # TODO: set as default image viewer

    # TODO: add `programs.ssh.*` options
    pkgs.openssh
  ]; 

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "en_IE.UTF-8/UTF-8"
  ];

  # programs.fastfetch.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
}
