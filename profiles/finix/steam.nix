{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.steam;

  extraCompatPaths = lib.makeSearchPathOutput "steamcompattool" "" cfg.extraCompatPackages;
in
{
  options.programs.steam = {
    enable = lib.mkEnableOption "steam";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.steam;
      defaultText = lib.literalExpression "pkgs.steam";
      example = lib.literalExpression ''
        pkgs.steam.override {
          extraEnv = {
            MANGOHUD = true;
            OBS_VKCAPTURE = true;
            RADV_TEX_ANISO = 16;
          };
          extraLibraries = p: with p; [
            atk
          ];
        }
      '';
      apply =
        steam:
        steam.override (
          prev:
          {
            extraLibraries =
              pkgs:
              let
                prevLibs = if prev ? extraLibraries then prev.extraLibraries pkgs else [ ];
                additionalLibs =
                  with config.hardware.graphics;
                  if pkgs.stdenv.hostPlatform.is64bit then
                    [ package ] ++ extraPackages
                  else
                    [ package32 ] ++ extraPackages32;
              in
              prevLibs ++ additionalLibs;
          }
        );
      description = ''
        The Steam package to use. Additional libraries are added from the system
        configuration to ensure graphics work properly.

        Use this option to customise the Steam package rather than adding your
        custom Steam to {option}`environment.systemPackages` yourself.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      # this fixes the "glXChooseVisual failed" bug, context: https://github.com/NixOS/nixpkgs/issues/47932
      enable = true;
      enable32Bit = true;
    };

    # enable 32bit pulseaudio/pipewire support if needed
    # services.pulseaudio.support32Bit = config.services.pulseaudio.enable;
    # services.pipewire.alsa.support32Bit = config.services.pipewire.alsa.enable;

    environment.systemPackages = [
      cfg.package
      cfg.package.run
    ];
  };
}
