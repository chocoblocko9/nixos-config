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
          (final: prev: {
            musl = prev.musl.overrideAttrs (oldAttrs: {
              nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ 
                prev.buildPackages.stdenv.cc.bintools
                # prev.buildPackages.binutils-unwrapped 
              ];

              makeFlags = (oldAttrs.makeFlags or []) ++ [
                "CROSS_COMPILE=x86_64-unknown-linux-musl-"
              ];

              NIX_CFLAGS_COMPILE = (oldAttrs.NIX_CFLAGS_COMPILE or "") 
                + " -Wno-error=implicit-function-declaration -Wno-error=int-conversion";
            });
              
            # Unfortunately necessary, nix hates being musl'd i guess
            nix = subvertpkgs.nix;
            nix-expr = subvertpkgs.nix-expr;
            
            stdenv = prev.stdenv.override (old: {
              extraAttrs = (old.extraAttrs or {}) // {
                NIX_CFLAGS_COMPILE = (old.extraAttrs.NIX_CFLAGS_COMPILE or "") 
                  + " -O3 -pipe -fno-plt";
              };
            });

            # Turn off tests because they fail like 1/493 on musl
            boehm-gc = prev.boehm-gc.overrideAttrs (old: {
              doCheck = false;
            });

            wayland = prev.wayland.overrideAttrs (old: {
              mesonFlags = (old.mesonFlags or []) ++ [
                "-Ddocumentation=false"
              ];
              outputs = ["out" "dev" ];
            });

            pipewire = (prev.pipewire.override {
  enableSystemd = false;
  udev = prev.libudev-zero;
}).overrideAttrs (o: {
  doCheck = false;
  NIX_CFLAGS_COMPILE = (o.NIX_CFLAGS_COMPILE or "") + " -Wno-error=nonnull -Wno-error=stringop-overread";
  patches = o.patches or [] ++ [ ./profiles/shift/pipewire.patch ];
});

            wireplumber = prev.wireplumber.override {
              pipewire = final.pipewire;
            };

            seatd = prev.seatd.override { systemdSupport = false; };

            gnutls = prev.gnutls.overrideAttrs (old: {
              doCheck = false;
            });

            libfaketime = prev.libfaketime.overrideAttrs (old: {
              doCheck = false;
              
              # use the 'env' attribute to consolidate flags cus modern or smth
              env = (old.env or {}) // {
                NIX_CFLAGS_COMPILE = toString [
                  "-include pthread.h"
                  "-Wno-implicit-function-declaration"
                  "-Wno-int-conversion"
                  "-Dforce_stat=1"
                ];
              };

              # no -Werror
              postPatch = (old.postPatch or "") + ''
                sed -i 's/-Werror//g' src/Makefile
              '';
            });

            perl = prev.perl.overrideAttrs (old: {
              doCheck = false;
              dontCheck = true;
              LC_ALL = "C.UTF-8";
            });

            perlPackages = prev.perlPackages // {
              Test2Harness = prev.perlPackages.Test2Harness.overrideAttrs { 
                doCheck = false; 
              };
            };
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
          inputs.hjem.finixModules.default
          {
            nixpkgs.pkgs = nixpkgs.lib.mkDefault subvertpkgs;
          }
          ./profiles/finix/configuration.nix

          # (toString nixpkgs + "/nixos/modules/programs/noisetorch.nix")

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
          {
            nixpkgs.pkgs = nixpkgs.lib.mkDefault muslpkgs;
            disabledModules = [ "${inputs.finix}/modules/security/wrappers/default.nix" ];
          }
          ./profiles/shift/configuration.nix

          # (toString nixpkgs + "/nixos/modules/programs/noisetorch.nix")

          bash
          dhcpcd
          getty
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
    finix.url = "github:finix-community/finix";
    finix-patch.url = "git+file:///home/conor/finix/wrappers";

    modular-services.url = "github:chocoblocko9/modular-services/fix-finit-check";
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hjem = {
      url = "github:r0chd/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
