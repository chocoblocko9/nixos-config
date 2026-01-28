{ inputs, config, pkgs, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ]; # Enable Flakes
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
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
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
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

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
 
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

  hardware.i2c.enable = true; # Enable i2c protocol for use with ddcutil (brightness changing)
  services.vnstat.enable = true;

  fonts.packages = with pkgs; [ 
    nerd-fonts._0xproto
    nerd-fonts.hack
    nerd-fonts.symbols-only 
    noto-fonts
  ];

  # Configure keyboard layout
  console.useXkbConfig = true;
  services.xserver.xkb = {
    layout = "de";
    variant = "qwerty";
  };

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
    vim
    wget
    git
    ddcutil # Program for changing monitor brightness from keyboard
  ];

  # Is this necessary? idk
  environment.sessionVariables = {
  	NIXOS_OZONE_WL = "1"; 
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 2234 25565 ];
  networking.firewall.allowedUDPPorts = [	2234 25565 ];

  system.stateVersion = "25.11";
}

