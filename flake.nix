{
  description = "System flake that I'm scared of (how does this work)";

  outputs = 
  	{ 
  		nixpkgs, 
      # nixvim,
      nix-on-droid,
  		... 
  	} @ inputs:
  	
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
    in {
    nixosConfigurations = {
      slip = lib.nixosSystem {
        specialArgs = { 
          inherit inputs; 
          inherit system;
        };
        modules = [ 
          inputs.hjem.nixosModules.default
          ./profiles/slip/hjem.nix
          ./profiles/slip/configuration.nix 
        ];
      };

      superliminal = lib.nixosSystem {
        specialArgs = { 
          inherit inputs; 
          inherit system;
        };
        modules = [
          ./profiles/superliminal/configuration.nix
          ./modules/system/modules.nix
        ];
      };

      sleepless = lib.nixosSystem {
        specialArgs = { 
	  			inherit inputs; 
          inherit system;
				};
        modules = [
          inputs.hjem.nixosModules.default
          ./profiles/sleepless/configuration.nix
          ./modules/system/modules.nix
        ];
      };
    };

    nixOnDroidConfigurations = {
      default = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs { system = "aarch64-linux"; };
        modules = [ 
          .profiles/squid/nix-on-droid.nix
        ];
      };
    };

    /*
    homeConfigurations = {
      "ezra@superliminal" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = [ 
        	./profiles/superliminal/home.nix
          ./modules/user/modules.nix
        ];
      };
    };
    */
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-2511.url = "nixpkgs/nixos-25.11";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    hyprland.url = "github:hyprwm/Hyprland?rev=8685fd7b0c2afe06c798554dea80c53f98d73894";

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mnw.url = "github:Gerg-L/mnw";
  };
}
