{ lib, config, ... }:

{
  options = {
    userSettings.mpdscribble = {
      enable = lib.mkEnableOption "Enable mpdscribble";
    };
  };

  config = lib.mkIf config.systemSettings.mpdscribble.enable {
    services.mpdscribble = {
		  enable = true;
		  journalInterval = 300;
		  endpoints = {
			  "last.fm" = {
				  url = "https://post.audioscrobbler.com/";
				  passwordFile = "/home/conor/Documents/lastfmpass";
			    username = "Choco988";
			  }; 
		  };
	  };

    environment.systemPackages = with pkgs; [
      cava
      # Ok this is kinda bad practice to have this hidden in here BUT
      # the logic is that there's no possible reason I'd ever want this
      # and not want mpdscribble because if I'm using mpdscribble then 
      # I'm using rmpc which then implies I'm using cava.

      # It has to be here because IDK, just breaks otherwise.
    ];
  };
}