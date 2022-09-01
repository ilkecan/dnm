{
  inputs,

  lib ? inputs.nixpkgs.lib,
  nix-alacarte ? inputs.nix-alacarte.lib,
}@args:

let
  inherit (nix-alacarte)
    mergeLibFiles
  ;

  args' = args // {
    inherit
      lib
      nix-alacarte

      dnm
      internal
    ;
  };

  dnm = mergeLibFiles ./. args' { };
  internal = import ./internal args';
in

dnm
