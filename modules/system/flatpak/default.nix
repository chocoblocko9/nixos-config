{ inputs, ... }:

{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  /*
  If I'm being real I kindaaa hate flatpak but like it's the only way
  to play ROBLOX and I definitely could not give that up for real
  */
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
}
