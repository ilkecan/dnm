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
    isList
    mapAttrsToList
    pipe
  ;

  inherit (nix-alacarte)
    boolToInt
    sum
  ;

  inherit (dnm.internal)
    fmtCounter
    fmtTestCase
    fmtTestList
    fmtTestSet
    isTestCase
    getTestSetResult
  ;

  getTestCaseResult = name: test:
    {
      str = "${name} ${fmtTestCase test}";
      stats = {
        passed = boolToInt test.passed;
        total = 1;
      };
    };

  getTestListResult = name: list:
    let
      testListResults = map (getTestCaseResult "-") list;
      stats = pipe testListResults [
        (map (getAttr "stats"))
        (zipAttrsWith (_: sum))
      ];
      header = "${name} ${fmtCounter stats}";
    in
    {
      str =
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
  getTestSetResult = name: value:
    if isList value then
      getTestListResult name value
    else if isTestCase value then
      getTestCaseResult name value
    else
      let
        testSetResults = mapAttrs getTestSetResult value;
        stats = pipe testSetResults [
          (mapAttrsToList (_: getAttr "stats"))
          (zipAttrsWith (_: sum))
        ];
        header = "${name} ${fmtCounter stats}";
      in
      {
        str =
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
