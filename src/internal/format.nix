{
  lib,
  nix-alacarte,
  ...
}:

let
  inherit (lib)
    getAttr
    mapAttrsToList
    removePrefix
  ;

  inherit (nix-alacarte)
    addPrefix
    indentBy
    pipe'
    unlines
  ;
in

{
  fmtCounter = { passed ? 0, total ? 0, ... }:
    "[${toString passed}/${toString total}]";

  fmtTestCase = { actual, expected, passed, ... }:
    if passed then
      "passed!"
    else
      ''
        failed:
          actual: ${builtins.toJSON actual}
          expected: ${builtins.toJSON expected}''
    ;

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
