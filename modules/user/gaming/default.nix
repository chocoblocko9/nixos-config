{ lib, config, pkgs, ... }:

/*
Hey there! You probably want to comment out lines 23-24 and 35-38 because they make this entire setup impure. 
Alternatively you can put in your own last.fm API keys and change the path or whatever, neither agenix nor 
sops-nix want to work for me so whatever :( Even if you do want to, you have to pass --impure during build
so yeahhh, not the best solution but it works. It's better than committing my API keys to github LOL.
*/

{
  options = {
    userSettings.gaming = {
      enable = lib.mkEnableOption "Enable gaming related programs and settings";
    };
  };

  config = lib.mkIf config.userSettings.gaming.enable {
    home.packages = with pkgs; [
      # Programs
      heroic # Good games launcher
      cemu # Wii U my beloved
      prismlauncher # Minecraft
      parallel-launcher
      streamlink 
    ];
    
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
      # basically this starts a VLC HTTP stream at localhost:8080 of the mau5trap
      # Airplane Mode 24/7 stream and Euro Truck Simulator can then download that
      # and play it as an in-game radio because it functions like any over the 
      # internet radio. Cool? Cool.
    };
  };
}