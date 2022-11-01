{
  dnm,
  lib,
  nix-alacarte,
  ...
}:

let
  inherit (lib)
    hasPrefix
  ;

  inherit (nix-alacarte)
    attrs
    bool
    fn
    list
    type
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
    color.${colorName} or fn.id;

  getTestCaseResult = depth: name: test:
    {
      fmt = if name == null then test.fmt else "${colorName depth name} ${test.fmt}";
      stats = {
        passed = bool.toInt test.passed;
        total = 1;
      };
    };

  getTestListResult = depth: name: list:
    let
      testListResults = list.imap (i: getTestCaseResult "${toString i}.") list;
      stats = fn.pipe testListResults [
        (list.map (attrs.get "stats"))
        (attrs.zipWith (_: list.sum))
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
    if type.isList value then
      getTestListResult depth name value
    else if isTestCase value then
      getTestCaseResult depth name value
    else
      let
        testSetResults = fn.pipe value [
          (attrs.filter (name: _: !hasPrefix "_" name))
          (attrs.map (getTestSetResult (depth + 1)))
        ];
        stats = fn.pipe testSetResults [
          (attrs.mapToList (_: attrs.get "stats"))
          (attrs.zipWith (_: list.sum))
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
