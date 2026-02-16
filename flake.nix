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
			stylix,
      agenix,
      nixvim,
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
          agenix.nixosModules.default
          ./profiles/slip/configuration.nix 
          ./modules/system/modules.nix
          {
            environment.systemPackages = [ 
              agenix.packages.${system}.default 
            ];
          }
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
          ./profiles/sleepless/configuration.nix
          ./modules/system/modules.nix
        ];
      };
    };

    homeConfigurations = {
      "conor@slip" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
					inherit nixpkgs-stable;
          inherit inputs;
        };
        modules = [ 
        	./profiles/slip/home.nix
          ./modules/user/modules.nix
        ];
      };

      "conor@sleepless" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = [ 
        	./profiles/sleepless/home.nix
          ./modules/user/modules.nix
        ];
      };

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

    nixcord.url = "github:FlameFlag/nixcord";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # hyprland.url = "github:hyprwm/Hyprland/v0.53.1?submodules=true";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hyprcursor-phinger.url = "github:jappie3/hyprcursor-phinger";

    home-manager = {
      url = "github:nix-community/home-manager/master"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
