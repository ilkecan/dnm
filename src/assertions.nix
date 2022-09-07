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

  inherit (lib.generators)
    toPretty
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

  toPretty' = toPretty { };
  mkTestCase = { passed, failureMessage }:
    {
      inherit passed;
      _type = testCaseType;
      fmt = if passed then "passed!" else "failed!${failureMessage}";
    };
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
        actual: ${toPretty' actual}
        expected: ${toPretty' expected}'');
    };

  assertFailure = expression:
    let
      f = { expression, ... }:
        let
          ret = tryEval expression;
          passed = !ret.success;
        in
        mkTestCase {
          inherit passed;
          failureMessage =
            " expected an error but got the value: ${toPretty' ret.value}";
        } // {
          inherit expression;
          __functor = self: arg:
            f { expression = self.expression arg; };
        };
    in
    f { inherit expression; };

  assertFalse = assertValue false;
  assertTrue = assertValue true;

  assertNull = assertValue null;

  assertValue = value:
    let
      f = expression:
        if isFunction expression then
          compose [ f expression ]
        else
          assertEqual { actual = expression; expected = value; }
        ;
    in
    f;
}
