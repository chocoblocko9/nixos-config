{ pkgs, ... }:

{
  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  programs = {
    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 5";
      };
      flake = "/home/conor/.files/"; # sets NH_OS_FLAKE variable for you
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
        set afterends
        set indicator
        set linenumbers
        set guidestripe 100
        set stripecolor bold,white,blue
      '';
    };
  };

  nix.settings.lazy-trees = true;

  networking = {
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 2234 ];
      allowedUDPPorts = [ 2234 ];
    };
  };

  services = {
    openssh.enable = true;
    vnstat.enable = true;
  
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

  environment.systemPackages = [ 
    pkgs.pavucontrol 
    pkgs.bluetuith
    pkgs.soteria
  ];
}
