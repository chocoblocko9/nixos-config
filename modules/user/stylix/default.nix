{ lib, config, pkgs, inputs, ... }:

{
  imports = [ inputs.stylix.homeModules.stylix ];

  options = {
    userSettings.stylix = {
      enable = lib.mkEnableOption "Enable stylix theming";
    };
  };

  config = lib.mkIf config.userSettings.stylix.enable {
    stylix = {
		  enable = true;
      base16Scheme = ./solarized.yaml;
      #image = ../hyprpaper/wallpapers/wallpaper.jpg;
      #polarity = "dark";
      targets = { 
        nixcord.enable = false;
        wofi.enable = false;
        kitty.enable = false;
        dunst.enable = false;
      };
      fonts = {
        monospace = {
          name = "JetBrainsMono Nerd Font";
          package = pkgs.nerd-fonts.jetbrains-mono;
        };
      };
      cursor = {
        # name = "Latte Blue";
        # package = pkgs.catppuccin-cursors.latteBlue;
        name = "Phinger Cursors";
        package = pkgs.phinger-cursors;
        size = 24;
      };
	  };
  };
}

/*
{
  scheme = "Solarized Dark";
  slug = "solarized-dark";
  author = "Ethan Schoonover (https://ethanschoonover.com/), modified by aramisgithub)";
  description = "Precision colors for machines and people";
  polarity = "dark";
  backgroundUrl = "https://r4.wallpaperflare.com/wallpaper/474/140/1011/stars-sea-clouds-night-wallpaper-7bede9caa0ccfc6d8a1eb0759c9972b0.jpg";
  backgroundSha256 = "sha256-ugnjfKCIpyH0enWB5l52j+1pWG1FwX8X5BeRh68NRuE=";
  base00 = "#011e25";
  base01 = "#073642";
  base02 = "#094554";
  base03 = "#0b5365";
  base04 = "#10697f";
  base05 = "#116e85";
  base06 = "#4d8796";
  base07 = "#fdf6e3";
  base08 = "#dc322f";
  base09 = "#cb4b16";
  base0A = "#b58900";
  base0B = "#dc322f";
  base0C = "#2aa198";
  base0D = "#268bd2";
  base0E = "#6c71c4";
  base0F = "#d33682";
}
palette:
  base00: "#002b36"
  base01: "#073642"
  base02: "#586e75"
  base03: "#657b83"
  base04: "#839496"
  base05: "#93a1a1"
  base06: "#eee8d5"
  base07: "#fdf6e3"
  base08: "#dc322f"
  base09: "#cb4b16"
  base0A: "#b58900"
  base0B: "#859900"
  base0C: "#2aa198"
  base0D: "#268bd2"
  base0E: "#6c71c4"
  base0F: "#d33682"
*/