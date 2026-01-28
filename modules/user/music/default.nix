{ lib, config, pkgs, ... }:

/*
Hey there! You probably want to comment out lines 23-24 and 35-38 because they make this entire setup impure. 
Alternatively you can put in your own last.fm API keys and change the path or whatever, neither agenix nor 
sops-nix want to work for me so whatever :( Even if you do want to, you have to pass --impure during build
so yeahhh, not the best solution but it works. It's better than committing my API keys to github LOL.
*/

{
  options = {
    userSettings.music = {
      enable = lib.mkEnableOption "Enable music listening stuff";
    };
  };

  config = lib.mkIf config.userSettings.music.enable {
    services = {
      rescrobbled = {
  		  enable = true;
  		  settings = {
  			  #filter-script = "path/to/script";
				  lastfm-key = "${config.home.sessionVariables.LASTFM_KEY}";
  		    lastfm-secret = "${config.home.sessionVariables.LASTFM_SECRET}"; 
			    #min-play-time = 0;
  			  player-whitelist = [ "Lollypop" ];
  			  use-track-start-timestamp = true;
			  };
  	  };
    };
    home.packages = with pkgs; [
      mprisence # discord RPC using mpris2
      lollypop # GNOME music player (my beloved)
      nicotine-plus # Soulseek
      puddletag # song file tagger
    ];
    home.sessionVariables = {
      LASTFM_KEY       = ~/Documents/lastfmkey; # horrible horrible bad bad dont do this 
      LASTFM_SECRET = ~/Documents/lastfmsecret; # WHY DOES AGENIX NOT WORK???
    };
  };
}