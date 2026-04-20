{ pkgs, lib, ... }:

{
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
}
