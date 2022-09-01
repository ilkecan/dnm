{
  alacarte,
  ...
}@args:

let
  inherit (alacarte)
    mergeLibFiles
  ;
in

mergeLibFiles ./. args { }
