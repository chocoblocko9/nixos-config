{ lib, config, ... }:

{
  options = {
    systemSettings.flatpak = {
      enable = lib.mkEnableOption "Enable flatpak through nix-flatpak";
    };
  };

  # If I'm being real I kindaaa hate flatpak but like it's the only way to play ROBLOX
  # and I definitely could not give that up for real

  config = lib.mkIf config.systemSettings.flatpak.enable {
    services.flatpak = {
      enable = true;
      packages = [
        "org.vinegarhq.Sober"
      ];
      overrides = {
        "org.vinegarhq.Sober".Context = {
          filesystems = [
            "xdg-run/app/com.discordapp.Discord:create" 
            "xdg-run/discord-ipc-0"
          ];  
        };
      };
    };
  };
}