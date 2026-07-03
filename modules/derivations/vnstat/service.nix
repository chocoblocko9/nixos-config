# Non-module dependencies (`importApply`)
{ formats, coreutils }:

# Service module
{
  lib,
  config,
  options,
  ...
}:
let
  cfg = config.vnstat;

  format = formats.iniWithGlobalSection { };
  configFile = format.generate "vnstat.conf" {
    globalSection = lib.filterAttrs (_: v: !lib.isAttrs v) cfg.settings;
    sections = lib.filterAttrs (_: lib.isAttrs) cfg.settings;
  };

  /*
  configFile = config.configData."tlshd.conf".path;
  #configFile = format.generate "vnstat.conf" {};
  format = formats.keyValue {
    mkKeyValue = lib.generators.mkKeyValueDefault { } " ";
  };
  */
in
{
  # https://nixos.org/manual/nixos/unstable/#modular-services
  _class = "service";

  options.vnstat = {
    package = lib.mkOption {
      description = "Package to use for vnstat.";
      defaultText = lib.literalMD "The `vnstat` package that provided this module.";
      type = lib.types.package;
    };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = ''
        Additional arguments to pass to `vnstat`. See {manpage}`vnstatd(8)`
        for additional details.
      '';
    };

    settings = lib.mkOption {
      description = ''
        Configuration for vnstat.
        See {manpage}`vnstat.conf(5)` for available options.
      '';
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
      default = { };
      example = lib.literalExpression ''
        {
          "authenticate.server" = {
            "x509.certificate" = "/var/lib/tlshd/cert.pem";
            "x509.private_key" = "/var/lib/tlshd/key.pem";
            "x509.truststore" = "/var/lib/tlshd/truststore.pem";
          };
        }
      '';
    };
  };

  config = {
    configData."vnstat.conf".text = lib.generators.mkKeyValueDefault { } cfg.settings;

    process.argv = [
      (lib.getExe cfg.package)
      (lib.optionalString (cfg.debug) "-D")
      "--config"
      configFile
    ];
  }
  // lib.optionalAttrs (options ? systemd) {
    systemd.service = {
      description = "vnStat network traffic monitor";
      path = [ coreutils ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      documentation = [
        "man:vnstatd(1)"
        "man:vnstat(1)"
        "man:vnstat.conf(5)"
      ];
      serviceConfig = {
        # Hardening (from upstream example service)
        ProtectSystem = "strict";
        StateDirectory = "vnstat";
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        PrivateTmp = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictNamespaces = true;

        #User = "vnstatd";
        #Group = "vnstatd";
      };
    };

  }
  // lib.optionalAttrs (options ? finit) {
    finit.services.vnstat = {
      description = "vnStat network traffic monitor";
      conditions = "service/syslogd/ready";
      # command = "${pkgs.vnstat}/bin/vnstatd " + lib.escapeShellArgs cfg.extraArgs;

      # TODO: reload confition? may be compilicated, will just do what finix does probably

      # when running in the foreground debug logs go to stdout
      log = lib.mkDefault cfg.debug;
    };
  };

  meta.maintainers = with lib.maintainers; [ choco98 ];
}
