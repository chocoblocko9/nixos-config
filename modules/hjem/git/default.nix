{ lib, config, pkgs, ... }:

{
  options = {
    hjemSettings.git = {
      enable = lib.mkEnableOption "Enable git related stuff";
    };
  };

  config = lib.mkIf config.hjemSettings.git.enable {
    hjem.users = {
      conor = {
        packages = [ pkgs.git ];
             
        
        # Let me run Doors from wofi
        files.".config/git/config".text = '' 
          [init]
            defaultBranch = "main"
          [user]
            email = "conorboyle07@protonmail.com"
            name = "Conor"
          [help]
            autocorrect = 1
       '';
      };
    };
  };
}
