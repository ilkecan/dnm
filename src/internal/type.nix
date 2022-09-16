{
  dnm,
  lib,
  ...
}:

let
  inherit (lib)
    isType
  ;

  inherit (dnm.internal)
    testCaseType
  ;
in

{
  testCaseType = "test-case";
  isTestCase = isType testCaseType;
}
