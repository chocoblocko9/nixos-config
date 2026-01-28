{

  description = "System flake that I'm scared of (how does this work)";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.11";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nixcord.url = "github:FlameFlag/nixcord";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland/v0.53.1?submodules=true";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = 
  	{ 
  		self, 
  		nixpkgs, 
  		nixpkgs-stable,
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
      pkgs-stable = nixpkgs-stable.legacyPackages.${system};
    in {
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [ 
          ./configuration.nix 
          nix-flatpak.nixosModules.nix-flatpak
        ];
      };
    };
    homeConfigurations = {
      conor = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ 
          {
          	imports = [ inputs.nixcord.homeModules.nixcord ];
            wayland.windowManager.hyprland = {
              enable = true;
              # set the flake package
              package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
              portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
              systemd.enable = false;
            };
          } 
          stylix.homeModules.stylix
        	./home.nix
        ];
        extraSpecialArgs = {
					inherit pkgs-stable;
        };
      };
    };
  };
}
