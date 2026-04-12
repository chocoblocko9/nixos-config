{
  description = "System flake that I'm scared of (how does this work)";

  outputs =
  	{ self, nixpkgs, finix, ... } @ inputs:

    let
      lib = nixpkgs.lib;
      finixpkgs = import nixpkgs {
        system = "x86_64-linux";

        config.allowUnfree = true;
        overlays = [
          self.overlays.custom
        ];
      };
    in {
      overlays.custom = final: prev: {
        seatd = prev.seatd.override { systemdSupport = false; };
        xdg-desktop-portal = prev.xdg-desktop-portal.override { enableSystemd = false; };
        xwayland-satellite = prev.xwayland-satellite.override { withSystemd = false; };
      };

    nixosConfigurations = {
      slip = lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          inputs.hjem.nixosModules.default
          ./profiles/slip/hjem.nix
          ./profiles/slip/configuration.nix
        ];
      };

      sleepless = lib.nixosSystem {
        specialArgs = {
		  			inherit inputs;
				};
        modules = [
          inputs.hjem.nixosModules.default
          ./profiles/sleepless/configuration.nix
          ./modules/system/modules.nix
        ];
      };

      finix = finix.lib.finixSystem {
        inherit (finixpkgs) lib;

        specialArgs = {
          modulesPath = toString nixpkgs + "/nixos/modules";
	  inherit inputs;
        };

        modules = with finix.nixosModules; [
          {
            nixpkgs.pkgs = nixpkgs.lib.mkDefault finixpkgs;
          }
          ./profiles/finix/configuration.nix

          # (toString nixpkgs + "/nixos/modules/programs/noisetorch.nix")

          anacron
          atd
          bash
          bluetooth
          brightnessctl
          chronyd
          ddccontrol
          dhcpcd
          dma
          dropbear
          earlyoom
          fcron
          fish
          fprintd
          fstrim
          fwupd
          getty
          gnome-keyring
          greetd
          hyprland
          hyprlock
          illum
          incus
          iwd
          labwc
          limine
          mariadb
          nftables
          niri
          nix-daemon
          nzbget
          openssh
          pmount
          polkit
          power-profiles-daemon
          regreet
          rtkit
          seahorse
          sudo
          sway
          sysklogd
          system76-scheduler
          tzupdate
          upower
          uptime-kuma
          virtualbox
          xwayland-satellite
          zerotierone
          zfs
          zzz
        ];
      }; 
    };
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    finix.url = "github:finix-community/finix";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # hyprland.url = "github:hyprwm/Hyprland";
    hyprlua = {
      url = "github:vaxerski/Hyprland/lua-lua-lua-lua-lua-lua-lua";
      # url = "git+file:///home/conor/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
