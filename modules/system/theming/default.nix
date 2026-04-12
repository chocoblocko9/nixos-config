{ pkgs, ... }:

{
  qt = {
    enable = true;
    style = "kvantum";
    platformTheme = "qt5ct";
  };

  environment.systemPackages = [ 
    pkgs.phinger-cursors 
    pkgs.rose-pine-hyprcursor
  ];

  fonts = {
    packages = [
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.nerd-fonts.symbols-only 
    ];
    fontconfig = {
      defaultFonts.monospace = [
        "JetBrainsMono Nerd Font"
      ];
    };
  };
}
