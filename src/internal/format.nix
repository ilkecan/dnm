{
  dnm,
  nix-alacarte,
  ...
}:

let
  inherit (nix-alacarte)
    attrs
    indentBy
    list
    pipe'
    unlines
  ;

  inherit (dnm.internal)
    color
  ;
in

{
  fmtCounter = { passed ? 0, total ? 0, ... }:
    "[${toString passed}/${toString total}]";

  fmtTestList = pipe' [
    (list.map (pipe' [
      (attrs.get "fmt")
      (indentBy 2)
    ]))
    unlines
  ];

  fmtTestSet = pipe' [
    (attrs.mapToList (_: attrs.get "fmt"))
    (list.map (indentBy 2))
    unlines
  ];

  fmtTestSummary = stats:
    ''
      test summary:
        ${color.green "passed"}: ${toString stats.passed}
        ${color.red "failed"}: ${toString (stats.total - stats.passed)}'';
}
