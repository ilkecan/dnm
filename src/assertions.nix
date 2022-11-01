{
  dnm,
  lib,
  nix-alacarte,
  ...
}:

let
  inherit (builtins)
    deepSeq
    tryEval
  ;

  inherit (lib.generators)
    toPretty
  ;

  inherit (nix-alacarte)
    float
    fn
    indentBy
    list
    str
    type
  ;

  inherit (dnm)
    assertEqual
    assertPredicate
    assertTrue
    assertValue
  ;

  inherit (dnm.internal)
    color
    fmtTestList
    testCaseType
  ;

  toPretty' = toPretty { };
  mkTestCase = { passed, failureMessage }:
    {
      inherit passed;
      _type = testCaseType;
      fmt = if passed then (color.green "passed!") else "${color.red "failed!"}${failureMessage}";
    };

  mkRightAssociative = fn':
    let
      self = expression:
        if type.isFn expression
          then fn.compose [ self expression ]
          else fn' expression;
    in
    self;
in

{
  assertAll = list':
    let
      failedAssertions = fn.pipe list' [
        (list.imap (index: assertion: { inherit index assertion; }))
        (list.filter (set: !set.assertion.passed))
        (list.map (set: { fmt = "${toString set.index}. ${set.assertion.fmt}"; }))
      ];
      passed = failedAssertions == [ ];
    in
    mkTestCase {
      inherit passed;
      failureMessage = str.prepend " " ''
        following assertions failed:
        ${fmtTestList failedAssertions}'';
    };

  assertEqual = { actual, expected }:
    let
      passed = actual == expected;
    in
    mkTestCase {
      inherit passed;
      failureMessage = str.prepend "\n" (indentBy 2 ''
        actual: ${toPretty' actual}
        expected: ${toPretty' expected}'');
    };

  assertFailure = expression:
    let
      fn = { expression, ... }:
        let
          ret = tryEval (deepSeq expression expression);
          passed = !ret.success;
        in
        mkTestCase {
          inherit passed;
          failureMessage =
            " expected an error but got a value: ${toPretty' ret.value}";
        } // {
          inherit expression;
          __functor = self: arg:
            fn { expression = self.expression arg; };
        };
    in
    fn { inherit expression; };

  assertFalse = assertValue false;
  assertTrue = assertValue true;

  assertNan = assertPredicate float.isNan;

  assertNull = assertValue null;

  assertPredicate = fn':
    mkRightAssociative (fn.compose [ assertTrue fn' ]);

  assertValue = value: mkRightAssociative (expression:
    assertEqual { actual = expression; expected = value; }
  );
}
