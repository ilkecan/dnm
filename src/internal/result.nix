{
  internal,
  lib,
  nix-utils,
  ...
}:

let
  inherit (builtins)
    getAttr
    mapAttrs
    zipAttrsWith
  ;

  inherit (lib)
    mapAttrsToList
    pipe
  ;

  inherit (nix-utils)
    boolToInt
    sum
  ;

  inherit (internal)
    fmtTestCase
    fmtTestGroup
    isTestCase
    getTestGroupResult
  ;

  getTestResult = name: test:
    {
      str = "${name} ${fmtTestCase test}";
      stats = {
        passed = boolToInt test.passed;
        total = 1;
      };
    };
in

{
  getTestGroupResult = name: set:
    if isTestCase set then
      getTestResult name set
    else
      let
        testGroupResults = mapAttrs getTestGroupResult set;
        stats = pipe testGroupResults [
          (mapAttrsToList (_: getAttr "stats"))
          (zipAttrsWith (_: sum))
        ];
        counter = "[${toString stats.passed}/${toString stats.total}]";
      in
      {
        str = ''
          ${name} ${counter}
          ${fmtTestGroup testGroupResults}'';
        inherit stats;
      }
    ;
}
