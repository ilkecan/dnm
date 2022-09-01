{
  inputs,
  lib ? inputs.nixpkgs.lib,
  nix-utils ? inputs.nix-utils.lib,
}@args:

let
  inherit (nix-utils)
    mergeLibFiles
  ;

  args' = args // {
    inherit
      lib
      nix-utils

      dnm
      internal
    ;
  };

  internal = import ./internal args';
  dnm = mergeLibFiles ./. args' { };
in

dnm
