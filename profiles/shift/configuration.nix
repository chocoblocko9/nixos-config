{ 
  config,
  pkgs,
  pkgsStatic,
  lib,
  inputs,
  ...
}:
let
  xdg-desktop-portal = pkgs.xdg-desktop-portal.override { enableSystemd = false; };

  libinput = pkgs.libinput.override {
    udev = pkgs.libudev-zero;
    wacomSupport = false;
  };

  aquamarine = pkgs.aquamarine.override {
    inherit libinput;

    udev = pkgs.libudev-zero;
  };

  hyprland = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.override {
    inherit aquamarine libinput;
    withSystemd = false;
  };

  xdph = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland.override {
    inherit hyprland;
  };
in
{
  imports = [
    ./pam.nix
    ./hardware-configuration.nix

    ./hjem.nix
  ];

  boot.loader.efi.canTouchEfiVariables = true;

  programs.limine.enable = true;
  programs.limine.settings.editor_enabled = true;

  environment.etc."security/limits.conf".text = ''
    @audio   -   rtprio     95
    @audio   -   nice       -19
    @audio   -   memlock    4194304
  '';

  time.timeZone = "Europe/Dublin";

  services.dbus.enable = true;

  boot.supportedFilesystems = {
    btrfs.enable = true;
    ntfs3.enable = true;
    ext4.enable = true;
  };

  boot.kernelParams = [ "loglevel=5" ];

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ./kernel.nix {});
  boot.initrd.availableKernelModules = lib.mkForce [
    "ahci"
    "nvme"
    "sd_mod"
    "xhci_hcd"
    "xhci_pci"
    "usbhid"
    "hid_generic"
    "rtc_cmos"
  ];

  finit.services.nix-daemon.environment.CURL_CA_BUNDLE = config.security.pki.caBundle;
  finit.services.nix-daemon.enable = true;
  finit.services.nix-daemon.path = [
    config.services.nix-daemon.package
    pkgs.util-linux
    config.services.openssh.package
  ];

  networking.hostName = "shift";

  finit.runlevel = 3;

  # services.dbus.enable = true;
  services.dhcpcd.enable = true;
    
  services.openssh.enable = true;
  services.sysklogd.enable = true;
  services.mdevd.enable = true;
  services.mdevd.nlgroups = 4;
  services.mdevd.debug = true;

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

  # services.polkit.enable = true;
  xdg.portal.enable = false;

  programs.bash.enable = true;
  programs.doas.enable = true;

  services.seatd.enable = true;

  finit.services.seatd.command = lib.mkForce "${pkgs.seatd.bin}/bin/seatd -n %n -u root -g ${config.services.seatd.group}";

  finit.cgroups = {
    system.settings."cpu.weight" = 100;
    user.settings."cpu.weight" = 100;
  };

  # NOTE: https://wiki.alpinelinux.org/wiki/Polkit#Using_polkit_with_seatd
  services.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("${config.services.seatd.group}") && action.id.startsWith("org.freedesktop.RealtimeKit1.")) {
        return polkit.Result.YES;
      }

      if (subject.isInGroup("${config.services.seatd.group}") && action.id.startsWith("org.freedesktop.UPower.PowerProfiles.")) {
        return polkit.Result.YES;
      }
    });
  '';

  i18n.glibcLocales = lib.mkForce pkgs.emptyDirectory;
  i18n.supportedLocales = [ "en_IE.UTF-8/UTF-8" "C.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];

  fonts.fontconfig.enable = true;

  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
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

  users.users.root.password = "$6$7luPjbNjbmrf1rvj$RAWwzn//WtL3PTm6LRjYqus1ELrAzXagWdmvroHVbPMP8.3Ze0.bzlQN4cRvGTgIfNlKQux6b0Yr2zn.ZvjZa.";

  users.users.conor = {
    isNormalUser = true;
    shell = pkgs.bash;
    group = "users";
    home = "/home/conor";
    createHome = true;
    password = "$6$7luPjbNjbmrf1rvj$RAWwzn//WtL3PTm6LRjYqus1ELrAzXagWdmvroHVbPMP8.3Ze0.bzlQN4cRvGTgIfNlKQux6b0Yr2zn.ZvjZa.";

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

  hardware.firmware = [ 
    (pkgs.runCommand "navy-flounder-firmware" {} ''
    mkdir -p $out/lib/firmware/amdgpu
    cp ${pkgs.linux-firmware}/lib/firmware/amdgpu/navy_flounder_* $out/lib/firmware/amdgpu/
  '')
  ];

  environment.systemPackages = [
    # pkgs.fastfetch
    pkgs.btop
    pkgs.foot

    pkgs.firefox

    pkgs.man
    pkgsStatic.nano
    pkgsStatic.vim
    pkgs.git
    pkgs.bintools

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

    pkgs.pipewire
    pkgs.wireplumber
    pkgs.iproute2

    pkgs.fish
    pkgs.musl

    pkgs.util-linux
    pkgs.e2fsprogs
    pkgs.kbd
  ];

  hardware.graphics.enable = true;
}
