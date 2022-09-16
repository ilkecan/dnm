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
    fmtTestSummary
    getTestSetResult
  ;
in

{
  runTests =
    {
      exclude ? [
        "data"
        "default.nix"
      ],
      name ? "tests",
    }:

    dir: args:
      let
        importTest = file:
          import file args;
        excludedPaths = map (filename: dir + "/${filename}") exclude;
        files = filesOf {
          inherit excludedPaths;
          asAttrs = true;
          withExtension = "nix";
        } dir;
        testResults = pipe files [
          (mapAttrs (_: importTest))
          (getTestSetResult 0 name)
        ];
      in
      ''
        ${testResults.fmt}

        ${fmtTestSummary testResults.stats}
      '';
}
