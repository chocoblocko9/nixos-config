# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.

  boot.supportedFilesystems = ["ntfs"];
  boot.loader = {
    systemd-boot.enable = false;

    grub = {
      enable = true;
      device = "nodev";
      # useOSProber = true;
      extraEntries = ''
      menuentry 'Windows Boot Manager (on /dev/nvme0n1p1)' --class windows --class os $menuentry_id_option 'osprober-efi-54A5-22B3' {
        insmod part_gpt
	      insmod fat
	      search --no-floppy --fs-uuid --set=root 54A5-22B3
	      chainloader /EFI/Microsoft/Boot/bootmgfw.efi
      }
      menuentry "System shutdown" {
        echo "System shutting down..."
        halt
      }
      menuentry 'Arch Linux (on /dev/sda5)' --class arch --class gnu-linux --class gnu --class os $menuentry_id_option 'osprober-gnulinux-simple-ec21-0eb4f241-ec21-4840-8321-4c66a2f2cd89' {
	      ismod part_msdos
	      ismod fat
	      set root='hd0,msdos3'
	      if [x $feature_platform_search_hint = xy ]; then
	        search --no-floppy --fs-uuid --set=root --hint-ieee1275='ieee1275//disk@0,msdos3' --hint-bios=hd0,msdos3 --hint-efi=hd1,msdos3 --hint-baremetal=ahcil,msdos3 E31D-C6D1
	      else
	        search --no-floppy --fs-uuid --set=root E31D-C6D1
	      fi
	      linux /vmlinuz-linux root=UUID=0eb4f241-ec21-4840-8321-4c66a2f2cd89 rw loglevel=3 quiet
	      initrd /initramfs-linux.img
      }
      '';
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };
  
  # fstab mounts
  fileSystems."/home/conor/1TB-Hard-Drive" = {
    device = "/dev/sdb2";
    fsType = "ntfs";
    options = [ "users" "nofail" "exec" ];
  };

  fileSystems."/home/conor/2TB-Hard-Drive" = {
    device = "/dev/sda2";
    fsType = "ntfs";
    options = [ "users" "nofail" "exec" ];
  };
 
  # Auto-mount USB (probably Ventoy)
  fileSystems."/home/conor/USB-Mount" = {
    device = "/dev/sdc1";
    options = [ "users" "nofail" ];
  };

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # Enable i2c protocol for use with ddcutil (brightness changing)
  hardware.i2c.enable = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Dublin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IE.UTF-8";
    LC_IDENTIFICATION = "en_IE.UTF-8";
    LC_MEASUREMENT = "en_IE.UTF-8";
    LC_MONETARY = "en_IE.UTF-8";
    LC_NAME = "en_IE.UTF-8";
    LC_NUMERIC = "en_IE.UTF-8";
    LC_PAPER = "en_IE.UTF-8";
    LC_TELEPHONE = "en_IE.UTF-8";
    LC_TIME = "en_IE.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "qwerty";
  };

  # Configure console keymap
  console.useXkbConfig = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.conor = {
    isNormalUser = true;
    description = "Conor";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    ddcutil
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.steam.enable = true;

 
  # Hyprland 
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };  

  environment.sessionVariables.NIXOS_OZONE_WL = "1"; 
  
 
  # Audio & Bluetooth
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
   
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };


  # List services that you want to enable:
  services.samba.enable = true;
  services.displayManager.ly = {
    enable = true;
    settings = {
      # Uses local setup.sh file because it can't find default with home manager managing bash I think? I feel like that shouldn't be it but this makes it work so hey!
      setup_cmd = "$HOME/.files/ly/lysetup.sh";

      # Config
      allow_empty_password = false;
      auth_fails = "8"; 
      default_input = "login";    
      full_color = true;
      save = true; # Future me: idk what this does either tbh lol

      # Keybinds
      shutdown_key = "F1";
      shutdown_cmd = "systemctl poweroff";
      restart_key = "F2";
      restart_cmd = "systemctl reboot";
      sleep_key = "F3";
      sleep_cmd = "systemctl sleep";
      brightness_down_key = "F5";
      brightness_down_cmd = "/nix/store/881kbvkx60vfglagli4wqz0ascz2icni-ddcutil-2.2.1/bin/ddcutil --sleep-multiplier .1 --bus=8 setvcp 10 - 10"; # this is horrible horrible code that is gonna break 
      brightness_up_key = "F6";
      brightness_up_cmd = "/nix/store/881kbvkx60vfglagli4wqz0ascz2icni-ddcutil-2.2.1/bin/ddcutil --sleep-multiplier .1 --bus=8 setvcp 10 + 10"; # whenever i upgrade but whatever i WILL fix it cus i'll have to

      # Styling
      animation = "colormix";
      colormix_col1 = "0xFF000000";
      colormix_col2 = "0x00009494";
      # colormix_col1 = "0x0066FF33";
      colormix_col3 = "0x00000080";
      asterisk = ">";
      bg = "0x00000000";
      bigclock = "en";
      bigclock_seconds = "true"; 
      clock = "%H:%M:%S %a, %d/%m/%Y";  
    };
  };
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}

