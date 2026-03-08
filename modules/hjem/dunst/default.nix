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
        offset="(40,20)"
        # origin="top-right"
        progress_bar="true"
        width="(0,400)"
      '';
    };
  };
}
