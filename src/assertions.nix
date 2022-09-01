{
  dnm,
  ...
}:

let
  inherit (builtins)
    tryEval
  ;

  inherit (dnm)
    assertEqual
    assertValue
  ;

  inherit (dnm.internal)
    testCaseType
  ;
in

{
  assertEqual = { actual, expected }:
    {
      inherit actual expected;
      _type = testCaseType;
      passed = actual == expected;
    };

  assertFailure = expression:
    assertEqual {
      actual = tryEval expression;
      expected = { success = false; value = false; };
    };

  assertFalse = assertValue false;
  assertNull = assertValue null;
  assertTrue = assertValue true;

  assertValue = value: expression:
    assertEqual { actual = expression; expected = value; };
}
