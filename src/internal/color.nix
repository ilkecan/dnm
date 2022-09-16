{
  lib,
  nix-alacarte,
  ...
}:

let
  inherit (lib)
    concatStrings
  ;

  inherit (nix-alacarte.ansi.controlFunctions.controlSequences.SGR)
    bold
    green
    red
    reset
  ;

  boldAnd = color: msg:
    concatStrings [ bold color msg reset ];
in
{
  color = {
    green = boldAnd green;
    red = boldAnd red;
  };
}
