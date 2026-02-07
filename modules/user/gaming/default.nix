{ lib, config, pkgs, nixpkgs-stable, ... }:

{
  options = {
    userSettings.gaming = {
      enable = lib.mkEnableOption "Enable gaming related programs and settings";
    };
  };

  config = lib.mkIf config.userSettings.gaming.enable {
    home.packages = 
  	(with pkgs; [
	    heroic # Good games launcher
      cemu # Wii U my beloved
      prismlauncher # Minecraft
      # parallel-launcher
      streamlink # thing for the ets2 radio stream
      (sm64coopdx.overrideAttrs { # update to 1.4.1
        pname = "sm64coopdx";
        version = "1.4.1";

        src = fetchFromGitHub {
          owner = "coop-deluxe";
          repo = "sm64coopdx";
          rev = "6092488d1c4fc741b16a0789ef9c08ec0279333f";
          hash = "sha256-BIdKKIp6q9Vp2DByXzT9CJzOszFhjriiWBEqFwUT28M=";
        };
      })
  	])

		++

  	(with nixpkgs-stable; [
			parallel-launcher # N64 emulator
      # newest version in unstable fails to build yippee!
  	]);


    # Don't even THINK about questioning it
    home.file = {
      ".local/share/applications/Doors.desktop".text = '' # Let me run Doors from wofi
        [Desktop Entry]
        Name=Doors
        Comment=Play doors on Roblox
        Type=Application
        Terminal=false
        Exec=firefox --new-window roblox://placeId=6516141723/
        Categories=Game;
      '';     
    };

    programs.bash.shellAliases = {
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
