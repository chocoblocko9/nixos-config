{ lib, config, pkgs, 
# nixpkgs-stable, 
... }:

{
  options = {
    hjemSettings.gaming = {
      enable = lib.mkEnableOption "Enable gaming related stuff";
    };
  };

  config = lib.mkIf config.hjemSettings.gaming.enable {
    hjem.users.conor = {
      packages = [
        #pkgs.heroic # Good games launcher
        #cemu # Wii U my beloved
        pkgs.prismlauncher # Minecraft
        pkgs.streamlink # thing for the ets2 radio stream
        #sm64coopdx
      ];
/*
      ++

      (with nixpkgs-stable; [
        parallel-launcher # N64 emulator
        # newest version in unstable fails to build yippee!
      ]);       
*/      
      # Let me run Doors from wofi
      files.".local/share/applications/Doors.desktop".text = '' 
        [Desktop Entry]
        Name=Doors
        Comment=Play doors on Roblox
        Type=Application
        Terminal=false
        Exec=xdg-open roblox://placeId=6516141723/
        Categories=Game;
      '';
    };

    environment.shellAliases = {
      ets2 = "streamlink -p vlc -a \"-vvv - --sout \#transcode{vcodec=none,acodec=mp3,ab=320,scodec=none}:standard{access=http,mux=raw,dst=127.0.0.1:8080}\" --twitch-disable-hosting --twitch-disable-ads https://www.youtube.com/watch?v=edqlOxtnvL0 144p"; 
      /*
      Basically this starts a VLC HTTP stream at localhost:8080 of the mau5trap
      Airplane Mode 24/7 stream and Euro Truck Simulator 2 can then download that
      and play it as an in-game radio because it functions like any over the 
      internet radio. Cool? Cool.
      */
    };
  };
}
