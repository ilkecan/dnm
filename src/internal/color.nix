{
  lib,
  nix-alacarte,
  ...
}:

let
  inherit (lib)
    concatStrings
    genAttrs
  ;

  inherit (nix-alacarte.ansi.controlFunctions.controlSequences)
    SGR
  ;

  boldAnd = color: msg:
    concatStrings [ SGR.bold color msg SGR.reset ];
in
{
  color = genAttrs [
    "blue"
    "green"
    "red"
    "yellow"
  ] (name: boldAnd SGR.${name});
}
