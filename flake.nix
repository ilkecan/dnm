{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    nix-utils = {
      url = "github:ilkecan/nix-utils";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, ... }@inputs:
    {
      lib = import ./src { inherit inputs; };
      libs.default = self.lib;
    };
}
