{ pkgs, ... }:

{
  programs.thunar = {
    enable = true;
    plugins = [ 
      pkgs.thunar-volman 
      pkgs.thunar-media-tags-plugin 
      pkgs.thunar-archive-plugin 
      pkgs.thunar-vcs-plugin 
    ];
  };
}
