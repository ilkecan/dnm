{
  nix-utils,
  ...
}@args:

let
  inherit (nix-utils)
    mergeLibFiles
  ;
in

mergeLibFiles ./. args { }
