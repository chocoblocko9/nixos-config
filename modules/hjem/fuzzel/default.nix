{ pkgs, lib, ... }:

{
  hjem.users.conor = {
    packages = [
      pkgs.fuzzel
    ];
    
    files.".config/fuzzel/fuzzel.ini" = {
      generator = lib.generators.toINI {};
      
      value = {
        border.width = 3;

        # RRGGBBAA
        colors = {
          background = "011e25ee";
          border = "0f5570dd";
          counter = "eee8d5ff"; 
          input = "cac6b8ff";
          match = "cecb00ff";
          placeholder = "657b83ff";
          prompt = "cac6b8ff";
          selection = "586e75ff";
          selection-match = "cecb00ff";
          selection-text = "cac6b8ff";
          text = "cac6b8ff";
        };

        main = {
          font = "DejaVu Sans:size=16";
          icon-theme = "Numix";
          use-bold = true;
          terminal = "kitty";
          width = 60;
          anchor = "top";
          y-margin = 8;
        };
      };
    };
  };
}
