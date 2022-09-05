{
  dnm,
  lib,
  nix-alacarte,
  ...
}:

let
  inherit (builtins)
    filter
    tryEval
  ;

  inherit (lib)
    imap1
    isFunction
    pipe
  ;

  inherit (nix-alacarte)
    addPrefix
    compose
    indentBy
  ;

  inherit (dnm)
    assertEqual
    assertValue
  ;

  inherit (dnm.internal)
    fmtTestList
    testCaseType
  ;

  mkTestCase = { passed, failureMessage }:
    {
      inherit passed;
      _type = testCaseType;
      fmt = if passed then "passed!" else "failed!${failureMessage}";
    };

  assertBool = bool: value:
    if isFunction value then
      compose [ (assertBool bool) value ]
    else
      assertValue bool value
    ;
in

{
  assertAll = list:
    let
      failedAssertions = pipe list [
        (imap1 (index: assertion: { inherit index assertion; }))
        (filter (set: !set.assertion.passed))
        (map (set: { fmt = "${toString set.index}. ${set.assertion.fmt}"; }))
      ];
      passed = failedAssertions == [ ];
    in
    mkTestCase {
      inherit passed;
      failureMessage = addPrefix " " ''
        following assertions failed:
        ${fmtTestList failedAssertions}'';
    };

  assertEqual = { actual, expected }:
    let
      passed = actual == expected;
    in
    mkTestCase {
      inherit passed;
      failureMessage = addPrefix "\n" (indentBy 2 ''
        actual: ${builtins.toJSON actual}
        expected: ${builtins.toJSON expected}'');
    };

  assertFailure = expression:
    let
      ret = tryEval expression;
      passed = !ret.success;
    in
    mkTestCase {
      inherit passed;
      failureMessage =
        " expected an error but got the value: ${builtins.toJSON ret.value}";
    };

  assertFalse = assertBool false;
  assertTrue = assertBool true;

  assertNull = assertValue null;

  assertValue = value: expression:
    assertEqual { actual = expression; expected = value; };
}
