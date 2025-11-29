{

  description = "System flake that I'm scared of (how does this work)";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    hyprland = {
      url = "github:hyprwm/Hyprland/v0.52.1?submodules=true";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, stylix, nix-flatpak, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit system;
        modules = [ 
          ./configuration.nix 
          stylix.nixosModules.stylix
          nix-flatpak.nixosModules.nix-flatpak
        ];
      };
    };
    homeConfigurations = {
      conor = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
  };

}
