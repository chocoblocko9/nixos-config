{ pkgs, ... }:

{
  hjem.users = {
    conor = {
      packages = [ pkgs.git ];
      
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
}
