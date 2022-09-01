{
  inputs ? assert false; "must be called with either 'inputs' or all of [ 'lib' 'nix-alacarte' ]",

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
    ;

    dnm = dnm // { inherit internal; };
  };

  dnm = mergeLibFiles ./. args' { };
  internal = import ./internal args';
in

dnm
