{ lib, ... }:

let
  inherit (lib) filter hasSuffix;
  inherit (lib.fileset) toList;
in {
  imports = filter (hasSuffix "default.nix") (toList ./.); 
  # imports = with lib; ./. |> fileset.toList |> filter (hasSuffix "default.nix") # maybe?
}
