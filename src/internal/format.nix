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
  fmtTestCase = { actual, expected, passed, ... }:
    if passed then
      "passed!"
    else
      ''
        failed:
          actual: ${builtins.toJSON actual}
          expected: ${builtins.toJSON expected}''
    ;

  fmtTestGroup = pipe' [
    (mapAttrsToList (_: getAttr "str"))
    (map (indentBy 2))
    unlines
  ];
}
