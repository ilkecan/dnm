{
  inputs,
  alacarte ? inputs.nix-alacarte.lib,
  lib ? inputs.nixpkgs.lib,
}@args:

let
  inherit (alacarte)
    mergeLibFiles
  ;

  args' = args // {
    inherit
      alacarte
      lib

      dnm
      internal
    ;
  };

  dnm = mergeLibFiles ./. args' { };
  internal = import ./internal args';
in

dnm
