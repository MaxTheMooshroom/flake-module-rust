
# Flake-Module for Specifying A Custom Rust Toolchain

A flake-module for [Flake-Parts](https://flake.parts) that
adds a `rust-bins` attribute to the `self'` `perSystem` argument,
and adds a `rustPlatform` `perSystem` argument.

## Quick-Start

```nix
{
  inputs =
    {
      nixpkgs.url = "github:NixOS/nixpkgs/26.05";
      flake-parts.url = "github:hercules-ci/flake-parts";
      rust-module.url = "github:MaxTheMooshroom/flake-module-rust";
    };

  outputs =
    { flake-parts, rust-module, ... }@inputs:
    flake-parts.lib.mkFlake
      { inherit inputs; }
      (
        { lib, ... }:
        {
          systems = lib.systems.flakeExposed;

          imports = [ rust-module.flakeModule ];

          rust.toolchain.file = ./rust-toolchain.toml;
          # OR
          rust.toolchain.config =
            {
              channel = "stable";
              profile = "default";
              components = [ "rust-src" "clippy" "rustfmt" /* ... */ ];
            };

          perSystem =
            { rustPlatform, ... }:
            {
              packages.default =
                rustPlatform.buildRustPackage
                  {
                    # ...
                  };
            };
        }
      );
}
```

