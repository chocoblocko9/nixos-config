# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  config = {
    systemSettings = {
      audio.enable = true;
      bluetooth.enable = true;
      firefox.enable = true;
      hyprland.enable = true;
      ly = {
        enable = true;
        profile = "slip";
      };
      nano.enable = true;
      networking.enable = true;
      nh.enable = true;
      obs.enable = true;
      polkit.enable = true;
      theming.enable = true;
      thunar.enable = true;
      vnstat.enable = true;
    };

  # Hyprland Cachix
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];

    experimental-features = [ "nix-command" "flakes" ];
  };  

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
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

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
  console.keyMap = "ie";
  services.xserver.xkb = {
    layout = "ie";
    variant = "";
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

  environment.sessionVariables = {
  	NIXOS_OZONE_WL = "1"; 
  };

  system.stateVersion = "25.11";
  };
}
