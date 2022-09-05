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
    let
      passed = actual == expected;
    in
    {
      inherit passed;
      _type = testCaseType;
      fmt =
        if passed then
          "passed!"
        else
          ''
            failed:
              actual: ${builtins.toJSON actual}
              expected: ${builtins.toJSON expected}''
        ;
    };

  assertFailure = expression:
    let
      ret = tryEval expression;
      passed = !ret.success;
    in
    {
      inherit passed;
      _type = testCaseType;
      fmt =
        if passed then
          "passed!"
        else
          ''
            failed:
              expected an error but got the value: ${builtins.toJSON ret.value}''
        ;
    };

  assertFalse = assertValue false;
  assertNull = assertValue null;
  assertTrue = assertValue true;

  assertValue = value: expression:
    assertEqual { actual = expression; expected = value; };
}
