{ pkgs, ... }:

{
 hjem.users.conor = {
    packages = [
      pkgs.kitty 
    ];

    files.".config/kitty/kitty.conf".text = ''
      font_family JetBrainsMono Nerd Font
      font_size 14

      shell_integration no-rc

      background #001e26
      background_blur 32
      background_opacity 0.700000
      confirm_os_window_close 0
    '';
  };
}
