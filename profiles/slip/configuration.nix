{ lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/system/modules.nix
    ];
  
 options = {
    userName = lib.mkOption { 
      default = "conor";  
      type = lib.types.str;
    };
  }; 

  config = {
    systemSettings = {
      audio.enable = true;
      bluetooth.enable = true;
      firefox.enable = true;
      flatpak.enable = true;
      gaming.enable = false;
      hyprland.enable = true;
      ly = {
        enable = true;
        profile = "slip";
      };
      nano.enable = true;
      networking.enable = true;
      nh.enable = true;
      niri.enable = false;
      obs.enable = true;
      plasma.enable = false;
      polkit.enable = true;
      shell.enable = true;
      theming.enable = true;
      thunar.enable = true;
      virtualisation.enable = false;
      vnstat.enable = true;
    };
   
    userName = "conor"; # For my hjem abstraction layer

    nix.settings = {
      # Hyprland Cachix
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];

      # Flakes 
      experimental-features = [ "nix-command" "flakes" ];
    };

    # turn off bloat
    documentation = {
      enable = false;
      man.enable = false;
      info.enable = false;
      doc.enable = false;
      dev.enable = false;
      nixos.enable = false;
    };

    # Bootloader & Kernel
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_19;
    boot.supportedFilesystems = ["ntfs"];
    boot.loader = {
      systemd-boot.enable = false;
  
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
  
      grub = {
        enable = true;
        device = "nodev";
        useOSProber = true;
        splashImage = ../../themes/solarized/bootloader-solarized.png;
        extraEntries = ''
          menuentry 'Windows Boot Manager (on /dev/nvme0n1p1)' --class windows --class os $menuentry_id_option 'osprober-efi-54A5-22B3' {
            insmod part_gpt
            insmod fat
            search --no-floppy --fs-uuid --set=root 54A5-22B3
            chainloader /EFI/Microsoft/Boot/bootmgfw.efi
          }
          menuentry 'Arch Linux (on 2TB Hard Drive)' --class arch --class gnu-linux --class gnu --class os $menuentry_id_option 'osprober-gnulinux-simple-ec21-0eb4f241-ec21-4840-8321-4c66a2f2cd89' {
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
          menuentry "Shutdown" {
            echo "System shutting down..."
            halt
          }
          menuentry 'Reboot to UEFI' --id 'uefi-firmware' {
            echo "Entering UEFI Settings..."
            fwsetup
          }
        '';
      };
    };
    
    # fstab mounts
    fileSystems."/home/conor/2TB-Hard-Drive" = {
      device = "/dev/disk/by-uuid/203EA3F63EA3C2E0";
      fsType = "ntfs";
      options = [ "users" "nofail" "exec" ];
    };
  
    fileSystems."/home/conor/1TB-Hard-Drive" = {
      device = "/dev/disk/by-uuid/98046F01046EE22C";
      fsType = "ntfs";
      options = [ "users" "nofail" "exec" ];
    };
  
    # Auto-mount USB (probably Ventoy)
    fileSystems."/home/conor/USB-Mount" = {
      device = "/dev/sdc1";
      options = [ "users" "nofail" ];
    };
  
    networking.hostName = "slip";
  
    # Locales
    time.timeZone = "Europe/Dublin";
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
  
    # Configure keyboard layout
    console.useXkbConfig = true;
    services.xserver.xkb = {
      layout = "eu";
      variant = "";
      options = "ctrl:swapcaps";
    };
  
    environment.systemPackages = [ pkgs.os-prober ];
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.conor = {
      isNormalUser = true;
      description = "Conor";
      extraGroups = [ "networkmanager" "wheel" ];
    };
  
    nixpkgs.config.allowUnfree = true;
    system.stateVersion = "25.11";
  };
}

