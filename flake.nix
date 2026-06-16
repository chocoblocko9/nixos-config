{
  description = "System flake that I'm scared of (how does this work)";

  outputs =
    { nixpkgs, finix, finix-old, ... } @ inputs:

    let
      lib = nixpkgs.lib;

      subvertpkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;

        overlays = [
          (final: prev: {
            libudev-garden = (prev.pkgs.callPackage ./profiles/finix/libudev-garden.nix {});
          })
        ];
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

        overlays = [ (import ./profiles/shift/musl-overlay.nix) ];
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

          inputs.community-modules.nixosModules.fastfetch

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

      # shift = finix-patch.lib.finixSystem {
      shift = finix-old.lib.finixSystem {
        inherit (muslpkgs) lib;

        specialArgs = {
          modulesPath = toString nixpkgs + "/nixos/modules";
	        inherit inputs;
          inherit (subvertpkgs) pkgsStatic;
        };

        modules = with finix-old.nixosModules; [
        # modules = with finix-patch.nixosModules; [
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
    # nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs.url = "git+file:///home/conor/nixpkgs?rev=007a93a1044bc9bab53dd4c6b1e81dde1f6748cc";
    finix.url = "github:chocoblocko9/finix/gardendevd-init";
    finix-old.url = "git+file:///home/conor/programming/finix/finix?rev=1f7ac982a6b2c76b2223845ea867c399fd8899a1";

    community-modules.url = "git+file:///home/conor/finix/fastfetch-init";
    modular-services.url = "github:chocoblocko9/modular-services/fix-finit-check";
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    hyprland = {
      # url = "github:hyprwm/Hyprland";
      url = "github:chocoblocko9/Hyprland/center-false-fix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hjem = {
      url = "github:r0chd/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
