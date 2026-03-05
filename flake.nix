{
  description = "System flake that I'm scared of (how does this work)";

  outputs = 
  	{ 
  		self, 
  		nixpkgs, 
  		nixpkgs-2511,
  		home-manager, 
  		nix-flatpak, 
  		hyprland,  
      agenix,
      nixvim,
      nix-on-droid,
  		... 
  	} @ inputs:
  	
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      nixpkgs-stable = nixpkgs-2511.legacyPackages.${system};
      nixpkgs-overlayed = import nixpkgs {
        system = "x86_64-linux";
        overlays = [
          # (final: prev: {
            # example = prev.callPackage ./overlays/example.nix {};
          # })
        ];
      };
    in {
    nixosConfigurations = {
      slip = lib.nixosSystem {
        inherit system;
        specialArgs = { 
          inherit inputs; 
          inherit nixpkgs-overlayed;
          inherit nixpkgs-stable;
        };
        modules = [ 
          inputs.hjem.nixosModules.default
          ./profiles/slip/configuration.nix 
          ./modules/system/modules.nix
        ];
      };

      superliminal = lib.nixosSystem {
        inherit system;
        specialArgs = { 
          inherit inputs; 
        };
        modules = [
          ./profiles/superliminal/configuration.nix
          ./modules/system/modules.nix
        ];
      };

      sleepless = lib.nixosSystem {
        inherit system;
        specialArgs = { 
	  			inherit inputs; 
	 				inherit nixpkgs-overlayed;
          inherit nixpkgs-stable;
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
        pkgs = import nixpkgs-2511 { system = "aarch64-linux"; };
        modules = [ 
          .profiles/squid/nix-on-droid.nix
        ];
      };
    };

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
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-2511.url = "nixpkgs/nixos-25.11";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    hyprland.url = "github:hyprwm/Hyprland";
    
    home-manager = {
      url = "github:nix-community/home-manager/master"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    /*
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };
    */

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-2511";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
