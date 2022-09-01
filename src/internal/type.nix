{
  internal,
  lib,
  ...
}:

let
  inherit (lib)
    isType
  ;

  inherit (internal)
    testCaseType
  ;
in

{
  testCaseType = "test-case";

  isTestCase = isType testCaseType;
}
