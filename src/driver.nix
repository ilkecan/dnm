{
  internal,
  lib,
  nix-alacarte,
  ...
}:

let
  inherit (builtins)
    mapAttrs
  ;

  inherit (lib)
    pipe
  ;

  inherit (nix-alacarte)
    filesOf
  ;

  inherit (internal)
    getTestGroupResult
  ;
in

{
  runTests = dir: args: {
    exclude ? [
      "data"
      "default.nix"
    ],
    name ? "tests",
  }:
    let
      importTest = file:
        import file args;
      excludedPaths = map (filename: dir + "/${filename}") exclude;
      files = filesOf dir {
        inherit excludedPaths;
        asAttrs = true;
        withExtension = "nix";
      };
      testResults = pipe files [
        (mapAttrs (_: importTest))
        (getTestGroupResult name)
      ];
    in
    ''
      ${testResults.str}

      test result:
        ${toString testResults.stats.passed} passed
        ${toString (testResults.stats.total - testResults.stats.passed)} failed
    '';
}
