{
  dnm,
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

  inherit (dnm.internal)
    fmtTestResult
    getTestSetResult
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
        (getTestSetResult name)
      ];
    in
    ''
      ${testResults.fmt}

      ${fmtTestResult testResults.stats}
    '';
}
