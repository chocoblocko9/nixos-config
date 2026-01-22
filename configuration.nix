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

#  boot.kernelPackages = pkgs.linuxPackages_latest;
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

  # "hardware" options
  hardware = {
    i2c.enable = true; # Enable i2c protocol for use with ddcutil (brightness changing)
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    amdgpu = {
      opencl.enable = true;
      initrd.enable = true;
      overdrive = { # GPU overclocking stuff
        enable = true;
        ppfeaturemask = "0xfffd7fff";
      };
    };
  };  

	services.mpdscribble = {
		enable = true;
#	  verbose = 3;
		journalInterval = 300;
		endpoints = {
			"last.fm" = {
#				url = "https://post.audioscrobbler.com/";
				passwordFile = "/home/conor/Documents/lastfmpass";
			  username = "Choco988";
			}; 
		};
	};

  services = {
    vnstat.enable = true;
    lact.enable = true;
    flatpak = {
      enable = true;
      packages = [
        "org.vinegarhq.Sober"
      ];
      overrides = {
        "org.vinegarhq.Sober".Context = {
          filesystems = [
            "xdg-run/app/com.discordapp.Discord:create" 
            "xdg-run/discord-ipc-0"
          ];  
        };
      };
    };
  };

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
    cava # HAS to be here for the rmpc visualiser to work, the home-manager module does not work for unknown reasons
    bluetuith 
  ];

  programs = {
  	obs-studio = {
			enable = true;
	  	enableVirtualCamera = true;
  	};
    steam.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [ thunar-volman thunar-media-tags-plugin thunar-archive-plugin thunar-vcs-plugin ];
    };
    nano = {
      enable = true;
      syntaxHighlight = true;
      nanorc = ''
        set softwrap
        set tabsize 2
        set zap
        set mouse
        set autoindent
      ''
    }
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
  };

  # Is this necessary? idk
  environment.sessionVariables = {
  	NIXOS_OZONE_WL = "1"; 
  };

  # Security options
  security = {
  	rtkit.enable = true;
  	soteria.enable = true;
  };

  # Audio
  services = {
    pulseaudio.enable = false;
    pipewire = {
      pulse.enable = true;
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
    };
  };

  # List services that you want to enable:
  services.displayManager.ly = {
    enable = true;
    settings = {
      # Uses local setup.sh file because it can't find default with home manager managing bash I think? I feel like that shouldn't be it but this makes it work so hey!
      setup_cmd = "$HOME/.files/scripts/ly/lysetup.sh";

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
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 2234 25565 ];
  networking.firewall.allowedUDPPorts = [	2234 25565 ];

  system.stateVersion = "25.11";

}

