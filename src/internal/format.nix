{
  lib,
  nix-alacarte,
  ...
}:

let
  inherit (lib)
    getAttr
    mapAttrsToList
  ;

  inherit (nix-alacarte)
    indentBy
    pipe'
    unlines
  ;
in

{
  fmtCounter = { passed ? 0, total ? 0, ... }:
    "[${toString passed}/${toString total}]";

  fmtTestList = pipe' [
    (map (pipe' [
      (getAttr "str")
      (indentBy 2)
    ]))
    unlines
  ];

  fmtTestSet = pipe' [
    (mapAttrsToList (_: getAttr "str"))
    (map (indentBy 2))
    unlines
  ];
}
