{ config, pkgs, ... }:

{
  hjem.users.${config.userName} = {
    packages = [ pkgs.dunst ];
    
    files.".config/dunst/dunstrc".text = ''
      [global]
      background="#000000C0"
      font="Monospace 12"
      frame_color="#073642"
      height="(0,325)"
      offset="(40,20)"
      # origin="top-right"
      progress_bar="true"
      width="(0,400)"
    '';
  };
}
