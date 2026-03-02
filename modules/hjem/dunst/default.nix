{ lib, config, pkgs, ... }:

{
  options = {
    hjemSettings.dunst = {
      enable = lib.mkEnableOption "Enable dunst";
    };
  };

  config = lib.mkIf config.hjemSettings.dunst.enable {
    hjem.users.${config.userName} = {
      packages = [ pkgs.dunst ];

      systemd.services.dunst = {
        enable = true;

        unitConfig = {
          Description = "Dunst notification daemon";
          Documentation = "man:dunst(1)";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };

        serviceConfig = {
          Type = "dbus";
          BusName = "org.freedesktop.Notifications";
          ExecStart = "${pkgs.dunst}/bin/dunst";
          ExecReload = "${pkgs.dunst}/bin/dunstctl reload";
        };
     };
      
      files.".config/dunst/dunstrc".text = ''
        [global]
        background="#000000C0"
        font="Monospace 12"
        frame_color="#073642"
        height="(0,325)"
        # icon_path="/run/current-system/sw/share/icons/hicolor/32x32/actions:/run/current-system/sw/share/icons/hicolor/32x32/animations:/run/current-system/sw/share/icons/hicolor/32x32/apps:/run/current-system/sw/share/icons/hicolor/32x32/categories:/run/current-system/sw/share/icons/hicolor/32x32/devices:/run/current-system/sw/share/icons/hicolor/32x32/emblems:/run/current-system/sw/share/icons/hicolor/32x32/emotes:/run/current-system/sw/share/icons/hicolor/32x32/filesystem:/run/current-system/sw/share/icons/hicolor/32x32/intl:/run/current-system/sw/share/icons/hicolor/32x32/legacy:/run/current-system/sw/share/icons/hicolor/32x32/mimetypes:/run/current-system/sw/share/icons/hicolor/32x32/places:/run/current-system/sw/share/icons/hicolor/32x32/status:/run/current-system/sw/share/icons/hicolor/32x32/stock:/home/conor/.nix-profile/share/icons/hicolor/32x32/actions:/home/conor/.nix-profile/share/icons/hicolor/32x32/animations:/home/conor/.nix-profile/share/icons/hicolor/32x32/apps:/home/conor/.nix-profile/share/icons/hicolor/32x32/categories:/home/conor/.nix-profile/share/icons/hicolor/32x32/devices:/home/conor/.nix-profile/share/icons/hicolor/32x32/emblems:/home/conor/.nix-profile/share/icons/hicolor/32x32/emotes:/home/conor/.nix-profile/share/icons/hicolor/32x32/filesystem:/home/conor/.nix-profile/share/icons/hicolor/32x32/intl:/home/conor/.nix-profile/share/icons/hicolor/32x32/legacy:/home/conor/.nix-profile/share/icons/hicolor/32x32/mimetypes:/home/conor/.nix-profile/share/icons/hicolor/32x32/places:/home/conor/.nix-profile/share/icons/hicolor/32x32/status:/home/conor/.nix-profile/share/icons/hicolor/32x32/stock:/nix/store/5pk09nz6ar8niq7agzsw3idhyam7qrqj-hicolor-icon-theme-0.18/share/icons/hicolor/32x32/actions:/nix/store/5pk09nz6ar8niq7agzsw3idhyam7qrqj-hicolor-icon-theme-0.18/share/icons/hicolor/32x32/animations:/nix/store/5pk09nz6ar8niq7agzsw3idhyam7qrqj-hicolor-icon-theme-0.18/share/icons/hicolor/32x32/apps:/nix/store/5pk09nz6ar8niq7agzsw3idhyam7qrqj-hicolor-icon-theme-0.18/share/icons/hicolor/32x32/categories:/nix/store/5pk09nz6ar8niq7agzsw3idhyam7qrqj-hicolor-icon-theme-0.18/share/icons/hicolor/32x32/devices:/nix/store/5pk09nz6ar8niq7agzsw3idhyam7qrqj-hicolor-icon-theme-0.18/share/icons/hicolor/32x32/emblems:/nix/store/5pk09nz6ar8niq7agzsw3idhyam7qrqj-hicolor-icon-theme-0.18/share/icons/hicolor/32x32/emotes:/nix/store/5pk09nz6ar8niq7agzsw3idhyam7qrqj-hicolor-icon-theme-0.18/share/icons/hicolor/32x32/filesystem:/nix/store/5pk09nz6ar8niq7agzsw3idhyam7qrqj-hicolor-icon-theme-0.18/share/icons/hicolor/32x32/intl:/nix/store/5pk09nz6ar8niq7agzsw3idhyam7qrqj-hicolor-icon-theme-0.18/share/icons/hicolor/32x32/legacy:/nix/store/5pk09nz6ar8niq7agzsw3idhyam7qrqj-hicolor-icon-theme-0.18/share/icons/hicolor/32x32/mimetypes:/nix/store/5pk09nz6ar8niq7agzsw3idhyam7qrqj-hicolor-icon-theme-0.18/share/icons/hicolor/32x32/places:/nix/store/5pk09nz6ar8niq7agzsw3idhyam7qrqj-hicolor-icon-theme-0.18/share/icons/hicolor/32x32/status:/nix/store/5pk09nz6ar8niq7agzsw3idhyam7qrqj-hicolor-icon-theme-0.18/share/icons/hicolor/32x32/stock"
        offset="(40,20)"
        origin="top-right"
        progress_bar="true"
        width="(0,400)"
      '';
    };
  };
}
