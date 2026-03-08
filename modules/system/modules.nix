{ lib, ... }:

{
  imports = with lib; 
    filter (hasSuffix "default.nix") (fileset.toList ./.); 
  # imports = with lib; ./. |> fileset.toList |> filter (hasSuffix "default.nix") # maybe?
}
