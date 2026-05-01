{
  description = "System flake that I'm scared of (how does this work)";

  outputs =
  	{ self, nixpkgs, finix, ... } @ inputs:

    let
      lib = nixpkgs.lib;

      finixpkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in {
    nixosConfigurations = {
      slip = lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          inputs.hjem.nixosModules.default
          ./profiles/slip/hjem.nix
          ./profiles/slip/configuration.nix
        ];
      };

      sleepless = lib.nixosSystem {
        specialArgs = { inherit inputs; };
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
          fcron
          getty
          greetd
          gnome-keyring
          iwd
          hyprland
          limine
          ly
          nftables
          nix-daemon
          openssh
          polkit
          regreet
          rtkit
          sudo
          sysklogd
          upower
          vnstat
          xserver
          zerotierone
          zfs
        ];
      }; 
    };
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    # finix.url = "github:finix-community/finix";
    finix.url = "git+file:///home/conor/mdevd/finix";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    hyprland.url = "github:hyprwm/Hyprland";

    hjem = {
      url = "github:r0chd/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
