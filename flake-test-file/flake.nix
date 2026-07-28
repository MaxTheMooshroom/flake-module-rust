{
  inputs =
    {
      rust-module =
        {
          flake = false;
          url = "path:/dev/null";
        };

      nixpkgs.url = "github:NixOS/nixpkgs/26.05";

      flake-parts.url = "github:hercules-ci/flake-parts";
      flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
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

          perSystem =
            { self', ... }:
            {
              packages =
                {
                  rust-bins = self'.rust-bins;
                };
            };
        }
      );
}
