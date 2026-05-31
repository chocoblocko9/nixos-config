{
  description = "System flake that I'm scared of (how does this work)";

  outputs =
  	{ nixpkgs, finix, finix-patch, ... } @ inputs:

    let
      lib = nixpkgs.lib;

      subvertpkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      muslpkgs = import nixpkgs {
        localSystem = {
          config = "x86_64-unknown-linux-musl";
          system = "x86_64-linux";
          gcc = {
            arch = "native";
            tune = "native";
          };
        };

        config = {
          allowUnfree = true;
          checkMeta = false;
        };

        overlays = [
          (import ./profiles/shift/musl-overlay.nix)

          (final: prev: {
            # leave me alone :(
            nix = subvertpkgs.nix;
            nix-expr = subvertpkgs.nix-expr;
          })
        ];
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
        inherit (subvertpkgs) lib;

        specialArgs = {
          modulesPath = toString nixpkgs + "/nixos/modules";
	        inherit inputs;
        };

        modules = with finix.nixosModules; [
          { nixpkgs.pkgs = nixpkgs.lib.mkDefault subvertpkgs; }
          ./profiles/finix/configuration.nix

          inputs.hjem.finixModules.default

          bash
          bluetooth
          chronyd
          dhcpcd
          fcron
          fwupd
          getty
          greetd
          gnome-keyring
          iwd
          limine
          ly
          nftables
          nix-daemon
          openssh
          polkit
          rtkit
          sudo
          sysklogd
          upower
          vnstat
          xserver
          virtualbox
          zerotierone
        ];
      }; 

      shift = finix-patch.lib.finixSystem {
        inherit (muslpkgs) lib;

        specialArgs = {
          modulesPath = toString nixpkgs + "/nixos/modules";
	        inherit inputs;
        };

        modules = with finix.nixosModules; [
          { nixpkgs.pkgs = nixpkgs.lib.mkDefault muslpkgs; }
          ./profiles/shift/configuration.nix

          inputs.hjem.finixModules.default 

          bash
          dhcpcd
          getty
          fwupd
          limine
          nftables
          nix-daemon
          openssh
          polkit
          rtkit
          doas
          sysklogd
        ];
      };
    };
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    finix.url = "git+file:///home/conor/programming/nix/finix/limine-fixes";
    finix-patch.url = "git+file:///home/conor/finix/wrappers";

    modular-services.url = "github:chocoblocko9/modular-services/fix-finit-check";
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    hyprland = {
      url = "github:vaxerski/Hyprland/motion-blur";
      # url = "github:chocoblocko9/Hyprland/center-false-fix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hjem = {
      url = "github:r0chd/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
