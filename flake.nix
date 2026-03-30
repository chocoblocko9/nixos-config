{
  description = "System flake that I'm scared of (how does this work)";

  outputs = 
  	{ nixpkgs, ... } @ inputs:
  	
    let
      lib = nixpkgs.lib;
    in {
    nixosConfigurations = {
      slip = lib.nixosSystem {
        specialArgs = { 
          inherit inputs; 
        };
        modules = [ 
          inputs.hjem.nixosModules.default
          ./profiles/slip/hjem.nix
          ./profiles/slip/configuration.nix 
        ];
      };

      sleepless = lib.nixosSystem {
        specialArgs = { 
	  			inherit inputs; 
				};
        modules = [
          inputs.hjem.nixosModules.default
          ./profiles/sleepless/configuration.nix
          ./modules/system/modules.nix
        ];
      };
    };
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    # nixpkgs-2511.url = "nixpkgs/nixos-25.11";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # hyprland.url = "github:hyprwm/Hyprland";
    hyprlua = {
      url = "github:vaxerski/Hyprland/lua-lua-lua-lua-lua-lua-lua";
      # url = "git+file:///home/conor/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
