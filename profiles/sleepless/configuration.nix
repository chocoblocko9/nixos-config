{ lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./hjem.nix 
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
      hyprland.enable = true;
      ly = {
        enable = true;
        profile = "sleepless";
      };
      nano.enable = true;
      networking.enable = true;
      nh.enable = true;
      obs.enable = true;
      polkit.enable = true;
      shell.enable = true;
      theming.enable = true;
      thunar.enable = true;
      vnstat.enable = true;
    };

  userName = "conor";

  nixpkgs.config.permittedInsecurePackages = [
    "electron-38.8.4" # no idea what's even using this tbh LMAO
  ];

  # Hyprland Cachix
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];

    experimental-features = [ "nix-command" "flakes" ];
  };

  environment.systemPackages = with pkgs; [
    git
  ];

  # Bootloader & Kernel
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.luks.devices."luks-780c6648-d69b-4952-985d-ce6cee1e7fb7".device = "/dev/disk/by-uuid/780c6648-d69b-4952-985d-ce6cee1e7fb7";
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };


  networking.hostName = "sleepless";

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

  # Configure keymap in X11
  console.useXkbConfig = true;
  services.xserver.xkb = {
    layout = "eu";
    variant = "";
    options = "ctrl:swapcaps";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.conor = {
    isNormalUser = true;
    description = "Conor";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "1800"; # Corresponds to half an hour
  };
  
  services = {
    logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate"; 
    libinput.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";
  };
}
