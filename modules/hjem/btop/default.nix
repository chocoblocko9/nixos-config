{ config, pkgs, lib, ... }:

# TODO: this is like top 1 things that could be a wrapper...

{
 options = {
    hjemSettings.btop = {
      enable = lib.mkEnableOption "Enable btop";
    };
  };

  config = lib.mkIf config.hjemSettings.btop.enable {

 hjem.users.conor = {
    packages = [ pkgs.btop-rocm ];

    files.".config/btop/btop.conf" = {
      generator = lib.generators.toKeyValue {};

      value = {
        color_theme = "solarized_dark";
        theme_background = false;
        true_color = true;

        vim_keys = true;
        rounded_corners = true;
        terminal_sync = true;

        shown_boxes = "cpu mem net proc gpu0";

        proc_tree = true;
      };
    };
  };
};
}
