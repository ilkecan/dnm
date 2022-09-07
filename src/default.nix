let
  missingDependantOf =
    import ./../submodules/missing-dependant-of.nix/default.nix {
      inputs = [
        "lib"
        "nix-alacarte"
      ];
    };
in

{
  inputs ? missingDependantOf.inputs,

  lib ? inputs.nixpkgs.lib,
  nix-alacarte ? inputs.nix-alacarte.lib,
  ...
}@args:

let
  inherit (nix-alacarte)
    mergeLibFiles
  ;

  args' = args // {
    inherit
      inputs

      lib
      nix-alacarte
    ;

    dnm = dnm // { inherit internal; };
  };

  dnm = mergeLibFiles ./. args' { };
  internal = import ./internal args';
in

dnm
