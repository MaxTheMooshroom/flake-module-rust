{ lib, flake-parts-lib, ... }:
let
  inherit (lib) mkOption types;
  inherit (flake-parts-lib) mkTransposedPerSystemModule;
in
mkTransposedPerSystemModule
  {
    name = "rust-bins";
    file = ./rust-bins.nix;
    option =
      mkOption
        {
          type = types.package;
          description = ''
            The aggregate set of rust packages, "rust-bins", as provided by
            [oxalica](https://github.com/oxalica/rust-overlay).
          '';
        };
  }
