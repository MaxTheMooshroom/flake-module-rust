{
  inputs =
    {
      # flake-test-file.url = ./flake-test-file;
      # flake-test-file.inputs.rust-module.follows = "";
      # flake-test-file.inputs.flake-parts.follows = "flake-parts";
      #
      # flake-test-config.url = ./flake-test-config;
      # flake-test-config.inputs.rust-module.follows = "";
      # flake-test-config.inputs.flake-parts.follows = "flake-parts";

      flake-parts.url = "github:hercules-ci/flake-parts";
      # flake-parts.inputs.nixpkgs-lib.follows = "flake-test-file/nixpkgs";

      rust-overlay.url = "github:oxalica/rust-overlay";
    };

  outputs =
    { flake-parts, rust-overlay, ... }@inputs:
    flake-parts.lib.mkFlake
      { inherit inputs; }
      (
        { lib, config, ... }:
        {
          systems = lib.systems.flakeExposed;

          imports = [ flake-parts.flakeModules.flakeModules ];

          flake.flakeModules =
            {
              default = config.flake.flakeModules.rust;

              rust = (import ./flake-module.nix) rust-overlay;
            };

          # perSystem =
          #   { inputs', self', pkgs, ... }:
          #   {
          #     checks =
          #       {
          #         flake-module-using-file =
          #           inputs'.flake-test-file.packages.rust-bins;
          #
          #         flake-module-using-config =
          #           inputs'.flake-test-config.packages.rust-bins;
          #       };
          #   };
        }
      );
}
