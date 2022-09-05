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
      (getAttr "fmt")
      (indentBy 2)
    ]))
    unlines
  ];

  fmtTestSet = pipe' [
    (mapAttrsToList (_: getAttr "fmt"))
    (map (indentBy 2))
    unlines
  ];

  fmtTestResult = stats:
    ''
      test result:
        ${toString stats.passed} passed
        ${toString (stats.total - stats.passed)} failed'';
}
