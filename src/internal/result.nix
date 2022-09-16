{
  dnm,
  lib,
  nix-alacarte,
  ...
}:

let
  inherit (builtins)
    getAttr
    mapAttrs
    zipAttrsWith
  ;

  inherit (lib)
    filterAttrs
    hasPrefix
    id
    imap1
    isList
    mapAttrsToList
    pipe
  ;

  inherit (nix-alacarte)
    boolToInt
    sum
  ;

  inherit (dnm.internal)
    color
    fmtCounter
    fmtTestList
    fmtTestSet
    getTestSetResult
    isTestCase
  ;

  colorName = depth:
    let
      colorName = {
        "1" = "yellow";
        "2" = "blue";
      }.${toString depth} or "";
    in
    color.${colorName} or id;

  getTestCaseResult = depth: name: test:
    {
      fmt = if name == null then test.fmt else "${colorName depth name} ${test.fmt}";
      stats = {
        passed = boolToInt test.passed;
        total = 1;
      };
    };

  getTestListResult = depth: name: list:
    let
      testListResults = imap1 (i: getTestCaseResult "${toString i}.") list;
      stats = pipe testListResults [
        (map (getAttr "stats"))
        (zipAttrsWith (_: sum))
      ];
      header = "${colorName depth name} ${fmtCounter stats}";
    in
    {
      fmt =
        if list == [ ] then
          header
        else
          ''
            ${header}
            ${fmtTestList testListResults}''
        ;
      inherit stats;
    };
in

{
  getTestSetResult = depth: name: value:
    if isList value then
      getTestListResult depth name value
    else if isTestCase value then
      getTestCaseResult depth name value
    else
      let
        testSetResults = pipe value [
          (filterAttrs (name: _: !hasPrefix "_" name))
          (mapAttrs (getTestSetResult (depth + 1)))
        ];
        stats = pipe testSetResults [
          (mapAttrsToList (_: getAttr "stats"))
          (zipAttrsWith (_: sum))
        ];
        header = "${colorName depth name} ${fmtCounter stats}";
      in
      {
        fmt =
          if value == { } then
            header
          else
            ''
              ${header}
              ${fmtTestSet testSetResults}''
          ;
        inherit stats;
      }
    ;
}
