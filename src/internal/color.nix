{
  nix-alacarte,
  ...
}:

let
  inherit (nix-alacarte)
    attrs
    string
  ;

  inherit (nix-alacarte.ansi.controlFunctions.controlSequences)
    SGR
  ;

  boldAnd = color: msg:
    string.concat [ SGR.bold color msg SGR.reset ];
in
{
  color = attrs.gen [
    "blue"
    "green"
    "red"
    "yellow"
  ] (name: boldAnd SGR.${name});
}
