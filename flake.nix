{
  description = "System flake that I'm scared of (how does this work)";
  /*
  nixConfig = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };
  */

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    pkgs-stable.url = "nixpkgs/nixos-25.11";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nixcord.url = "github:FlameFlag/nixcord";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland/v0.53.3?submodules=true";
    hyprcursor-phinger.url = "github:jappie3/hyprcursor-phinger";
    home-manager = {
      url = "github:nix-community/home-manager/master"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = 
  	{ 
  		self, 
  		nixpkgs, 
  		pkgs-stable,
  		home-manager, 
  		nix-flatpak, 
  		hyprland,  
			stylix,
  		... 
  	} @ inputs:
  	
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      nixpkgs-stable = pkgs-stable.legacyPackages.${system};
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
        };
        modules = [ 
          ./profiles/slip/configuration.nix 
          ./modules/system/default.nix
        ];
      };

      superliminal = lib.nixosSystem {
        inherit system;
        specialArgs = { 
          inherit inputs; 
        };
        modules = [
          ./profiles/superliminal/configuration.nix
          ./modules/system/default.nix
        ];
      };

      sleepless = lib.nixosSystem {
        inherit system;
        specialArgs = { 
	  			inherit inputs; 
	 				inherit nixpkgs-overlayed;
				};
        modules = [
          ./profiles/sleepless/configuration.nix
          ./modules/system/default.nix
        ];
      };
    };

    homeConfigurations = {
      conor = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
					inherit nixpkgs-stable;
          inherit inputs;
        };
        modules = [ 
        	./profiles/slip/home.nix
          ./modules/user/default.nix
        ];
      };

      conor-sleepless = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = [ 
        	./profiles/sleepless/home.nix
          ./modules/user/default.nix
        ];
      };

      ezra = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = [ 
        	./profiles/superliminal/home.nix
          ./modules/user/default.nix
        ];
      };
    };
  };
}
