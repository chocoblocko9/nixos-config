{ lib, ... }:

{
  imports = with lib; 
    filter 
      (hasSuffix "default.nix") # function (only returns paths ending in 'default.nix')
      (fileset.toList ./.); # list to operate on (recursively returns every path from current directory)
}
/*
Generates a list of all files ending in "default.nix" in this directory.
This intentionally excludes anything in ./module-name/config/example.nix
for no particular reason, other than it's cleaner to not have it import those
and that feels like something that would cause the most random bugs ever.
*/