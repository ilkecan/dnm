{
  nix-alacarte,
  ...
}@args:

let
  inherit (nix-alacarte)
    mergeLibFiles
  ;
in

mergeLibFiles ./. args { }
