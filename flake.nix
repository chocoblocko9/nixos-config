{

  description = "System flake that I'm scared of (how does this work)";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.11";

    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nixcord.url = "github:FlameFlag/nixcord";

    hyprland.url = "github:hyprwm/Hyprland/v0.53.1?submodules=true";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
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
  		... 
  	} @ inputs:

    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-stable = nixpkgs-stable.legacyPackages.${system};
      profile = "Slip"; # Change this to configure what profile you're building
    in {
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [ 
          (./. + "/profiles/${profile}/configuration.nix")
          ./modules/system/default.nix
          nix-flatpak.nixosModules.nix-flatpak
        ];
      };
    };
    homeConfigurations = {
      conor = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          (./. + "/profiles/${profile}/home.nix")
          ./modules/user/default.nix
          inputs.nixcord.homeModules.nixcord
        ];
        extraSpecialArgs = {
          inherit pkgs-stable;
        };
      };
    };
  };
}

