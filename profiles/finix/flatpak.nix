{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.flatpak;
in
{
  options.services.flatpak = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.flatpak.override { withSystemd = false; };
      defaultText = lib.literalExpression "pkgs.flatpak";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
      pkgs.fuse3
    ];

    services.polkit.enable = true;

    # fonts.fontDir.enable = true;

    services.dbus.packages = [ cfg.package ];

    users.users.flatpak = {
      description = "Flatpak system helper";
      group = "flatpak";
      isSystemUser = true;
    };

    users.groups.flatpak = { };
  };
}
