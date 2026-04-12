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
in
{
  imports = [
    ./hardware-configuration.nix
    ./pam.nix
    # ./podman.nix
  ];

  # experiment with network namespace support for finix
  # finit.ttys.tty1.extraConfig = "netns:zerotier";
  # finit.services.zerotierone.extraConfig = "netns:zerotier";
  # boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  # finit.package = pkgs.finit.overrideAttrs (finalAttrs: {
  #   patches = finalAttrs.patches or [ ] ++ [ /home/aaron/code/finit/netns-support.patch ];
  # });

  # wip - cups module
  # services.cups.enable = true;

  # experiment with user level service manager... dinit
  # finit.services.dinit-user-spawn = {
  #   command = pkgs.callPackage ./dinit-user-spawn.nix { };
  #   runlevels = "234";
  #   conditions = "service/syslogd/ready";
  #   cgroup.name = "user";
  #   log = true;
  # };

  specialisation.udev = {
    services.mdevd.enable = lib.mkForce false;
    services.udev.enable = lib.mkForce true;
  };

  specialisation.elogind = {
    services.mdevd.enable = lib.mkForce false;
    services.udev.enable = lib.mkForce true;

    services.elogind.enable = lib.mkForce true;
    services.seatd.enable = lib.mkForce false;
  };

  boot.loader.efi.canTouchEfiVariables = true;

  programs.limine.enable = true;
  programs.limine.settings.editor_enabled = true;

  programs.pmount.enable = true;

  security.pam.environment = {
    SSH_ASKPASS.default = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";

    # https://wiki.nixos.org/wiki/Accelerated_Video_Playback#Intel
    LIBVA_DRIVER_NAME.default = "iHD";
  };

  # TODO: some sort of option i guess
  environment.etc."security/limits.conf".text = ''
    @audio   -   rtprio     95
    @audio   -   nice       -19
    @audio   -   memlock    4194304
  '';

  boot.kernelParams = [
    "loglevel=1"

    # https://community.frame.work/t/linux-battery-life-tuning/6665/156
    "nvme.noacpi=1"
  ];

  # TODO: options for nix remote builders
  environment.etc."nix/machines".enable = false;
  environment.etc."nix/machines".text =
    lib.concatMapStringsSep "\n" (v: "ssh://${v}.node x86_64-linux - 20 2 benchmark,big-parallel - -")
      [
        "arche"
        "callisto"
        "europa"
        "helike"
        "herse"
        "kore"
        # "metis"
      ];

  finit.services.nix-daemon.environment.CURL_CA_BUNDLE = config.security.pki.caBundle;
  finit.services.nix-daemon.path = [
    config.services.nix-daemon.package
    pkgs.util-linux
    config.services.openssh.package
  ];

  networking.hostName = "subvert";

  finit.runlevel = 3;

  # TODO: create a base system profile
  services.chrony.enable = true;
  services.dbus.enable = true;
  services.earlyoom.enable = true;
  services.earlyoom.extraArgs = [
    "-r"
    "3600"
  ];
  services.fwupd.enable = true;
  services.fwupd.debug = false;
  services.illum.enable = true;
  services.dhcpcd.enable = true;
  services.iwd.enable = true;
  services.nix-daemon.enable = true;
  services.nix-daemon.nrBuildUsers = 32;
  services.nix-daemon.settings = {
    experimental-features = [
      "nix-command"
      "pipe-operators"
    ];
    download-buffer-size = 524288000;
    fallback = true;
    log-lines = 25;
    warn-dirty = false;
    builders-use-substitutes = true;
    build-dir = "/var/tmp";

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
  programs.fish.enable = true;
  programs.virtualbox.enable = true;
  programs.brightnessctl.enable = true;
  programs.sudo.enable = true;
  programs.zzz.enable = true;

  # https://forums.virtualbox.org/viewtopic.php?p=556540#p556540
  environment.etc."modprobe.d/blacklist-kvm.conf".text = ''
    # kernel 6.12 and later ship with kvm enabled by default, which breaks vbox
    blacklist kvm
    blacklist kvm_intel
  '';

  # TODO: create graphical desktop profiles
  services.rtkit.enable = true;
  services.bluetooth.enable = true;
  services.seatd.enable = true;
  services.ddccontrol.enable = true;
  programs.regreet.enable = true;
  programs.regreet.compositor = {
    extraArgs = [
      "-d"
      "-s"
      "-m"
      "last"
    ];
    environment = {
      XKB_DEFAULT_LAYOUT = "eu";
    };
  };
  programs.hyprland.enable = true;
  programs.hyprland.package = inputs.hyprlua.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.overrideAttrs {
    patches = [ ./../../overlays/fix-desync.patch ];
  };
  programs.seahorse.enable = true;
  programs.xwayland-satellite.enable = true;

  services.system76-scheduler.enable = true;
  services.system76-scheduler.configFile = pkgs.writeText "config.kdl" ''
    version "2.0"

    process-scheduler enable=true {
      refresh-rate 60
      execsnoop true

      assignments {
        // Keep nix-daemon deprioritized as a backup
        nix-daemon io=(idle)4 sched="idle" nice=19 {
          include cgroup="/system/nix-daemon"
        }
      }
    }
  '';

  finit.services.nix-daemon.cgroup.settings = {
    "cpu.max" = "800000 100000";
    "cpu.weight" = 50;
    "io.weight" = 50;
  };

  # misc
  services.fprintd.enable = true;
  services.fstrim.enable = true;
  services.tzupdate.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.zerotierone.enable = true;
  services.incus.enable = true;
  finit.services.incusd = lib.mkIf config.services.incus.enable {
    manual = true;
  };

  # NOTE: https://wiki.alpinelinux.org/wiki/Polkit#Using_polkit_with_seatd
  services.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      // allow user "conor" to utilize the fingerprint reader
      // not great for security but acceptible given this is a single user laptop... i guess
      if (subject.user == "conor" && action.id.startsWith("net.reactivated.fprint.device.")) {
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
    pkgs.xdg-desktop-portal-gnome
    pkgs.xdg-desktop-portal-gtk
  ];

  services.dbus.packages = [
    pkgs.dconf
  ];

  fonts.fontconfig.enable = true;

  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    font-awesome
    liberation_ttf
    mplus-outline-fonts.githubRelease
    nerd-fonts._0xproto
    nerd-fonts.droid-sans-mono
    noto-fonts
    noto-fonts-color-emoji
    proggyfonts
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
      users = [ "conor" ];
      requirePassword = false;
    }
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
    shell = pkgs.fish;
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
    pkgs.lollypop
    pkgs.cava

    pkgs.ddcutil
    pkgs.kitty
    pkgs.kanshi
    pkgs.musikcube

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
    pkgs.steam
    pkgs.steam.run
    pkgs.xarchiver
    pkgs.vesktop
    pkgs.quickshell

    pkgs.libnotify
    pkgs.wiremix
    pipewire'
    pkgs.pavucontrol
    
    pkgs.pmutils # isn't zzz doing this now?
    wireplumber'
    pkgs.wl-clipboard
    pkgs.xdg-utils

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

  # https://wiki.nixos.org/wiki/Accelerated_Video_Playback#Intel
  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];
  hardware.graphics.extraPackages32 = [ pkgs.pkgsi686Linux.intel-media-driver ];
}
