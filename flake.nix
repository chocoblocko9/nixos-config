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

      subvert = finix.lib.finixSystem {
        inherit (finixpkgs) lib;

        specialArgs = {
          modulesPath = toString nixpkgs + "/nixos/modules";
	        inherit inputs;
        };

        modules = with finix.nixosModules; [
          inputs.hjem.finixModules.default
          {
            nixpkgs.pkgs = nixpkgs.lib.mkDefault finixpkgs;
          }
          ./profiles/finix/configuration.nix

          # (toString nixpkgs + "/nixos/modules/programs/noisetorch.nix")

          bash
          bluetooth
          chronyd
          dhcpcd
          earlyoom
          fcron
          getty
          greetd
          hyprland
          iwd
          limine
          nftables
          niri
          nix-daemon
          openssh
          polkit
          regreet
          rtkit
          sudo
          sysklogd
          system76-scheduler
          upower
          uptime-kuma
          virtualbox
          zerotierone
          zfs
        ];
      }; 
    };
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    finix.url = "github:chocoblocko9/finix/init-vnstat";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # hyprland.url = "github:hyprwm/Hyprland";
    hyprlua = {
      url = "github:vaxerski/Hyprland/lua-lua-lua-lua-lua-lua-lua";
      # url = "git+file:///home/conor/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hjem = {
      url = "github:r0chd/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
