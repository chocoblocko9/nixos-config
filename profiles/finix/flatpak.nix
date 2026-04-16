{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.flatpak;
in
{
  options = {
    services.flatpak = {
      enable = lib.mkEnableOption "flatpak";
      package = lib.mkPackageOption pkgs "flatpak" { };
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = (config.xdg.portal.enable == true);
        message = "To use Flatpak you must enable XDG Desktop Portals with xdg.portal.enable.";
      }
    ];

    environment.systemPackages = [
      pkgs.flatpak
      pkgs.fuse3
    ];

    services.polkit.enable = true;

    # Fix for privilege checking only working on (e)logind
    services.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.Flatpak.app-install" ||
             action.id == "org.freedesktop.Flatpak.runtime-install" ||
             action.id == "org.freedesktop.Flatpak.app-uninstall" ||
             action.id == "org.freedesktop.Flatpak.runtime-uninstall" ||
             action.id == "org.freedesktop.Flatpak.modify-repo" ||
             action.id == "org.freedesktop.Flatpak.update-remote" ||
             action.id == "org.freedesktop.Flatpak.app-update" ||
             action.id == "org.freedesktop.Flatpak.runtime-update") &&
            subject.isInGroup("wheel")) {
              return polkit.Result.YES;
        }
      });
    '';

    # revokefs-fuse needs setuid, so copy it /run/wrappers/bin instead of the nix store
    /*
    security.wrappers.revokefs-fuse = {
      source = "${pkgs.flatpak}/libexec/revokefs-fuse";
      setuid = true;
      owner = "root";
      group = "root";
    };
    */

    /*
    finit.services.flatpak-system-helper = {
      conditions = [ "service/dbus/ready" ];
      command = "${pkgs.flatpak}/libexec/flatpak-system-helper";
      notify = "none";
      environment.FLATPAK_REVOKEFS_FUSE="/run/wrappers/bin/revokefs-fuse"; 
    };
    */

    services.dbus.packages = [ pkgs.flatpak ];

    environment.pathsToLink = [
      "/share/dbus-1"
      "/share/polkit-1/actions"
      "/share/polkit-1/rules.d"
    ];

    users.users.flatpak = {
      description = "Flatpak system helper user";
      group = "flatpak";
      isSystemUser = true;
    };

    users.groups.flatpak = { };


    /*
    # Hacky, can't use /var/tmp because of permission conflicts with nix
    security.pam.environment.FLATPAK_SYSTEM_CACHE_DIR.default = "/var/lib/flatpak/cache";

    finit.tasks.flatpak-setup = {
      description = "create flatpak directories";
      runlevels = "S";
      command = pkgs.writeShellScript "flatpak-setup" ''
        mkdir -p /var/lib/flatpak
        chown flatpak:flatpak /var/lib/flatpak
        mkdir -p /var/lib/flatpak/cache
        chown flatpak:flatpak /var/lib/flatpak/cache
        chmod 1777 /var/lib/flatpak/cache
      '';
    };
    */
  };
}
