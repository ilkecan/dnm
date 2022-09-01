{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    nix-alacarte = {
      url = "github:ilkecan/nix-alacarte";
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
