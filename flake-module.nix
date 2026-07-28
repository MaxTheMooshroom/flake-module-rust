rust-overlay:
{ inputs, lib, ... }:
let
  inherit (lib) mkOption types;
  inherit (mkOption {}) _type;

  channel-pattern =
      "^(stable|beta|nightly|[0-9]+\\.[0-9]+\\."
    + "[0-9]+)(-[0-9]{4}-[0-9]{2}-[0-9]{2})?"
    + "(-[A-Za-z0-9_]+-[A-Za-z0-9_]+-[A-Za-z0-9_]+)?$";

  rust-components =
    [
      "rustc"
      "cargo"
      "rustfmt"
      "rust-std"
      "rust-docs"
      "rust-analyzer"
      "clippy"
      "miri"
      "rust-src"
      "rust-mingw"
      "rustc-dev"
    ];

  rust-profiles =
    [
      "minimal"
      "default"
      "complete"
    ];
in
{
  imports =
    [
      ./rust-bins.nix

      {
        options.rust =
          {
            toolchain =
              {
                inherit _type;
                type =
                  types.attrTag
                    {
                      file =
                        {
                          inherit _type;
                          type = types.nullOr types.pathInStore;
                          default = null;
                        };

                      config =
                        {
                          inherit _type;
                          type =
                            types.submodule
                              {
                                options =
                                  {
                                    channel =
                                      {
                                        inherit _type;
                                        default = null;
                                        type =
                                          types.nullOr
                                            (types.strMatching channel-pattern);
                                      };

                                    components =
                                      {
                                        inherit _type;
                                        default = null;
                                        type =
                                          types.nullOr
                                            (types.listOf
                                              (types.enum rust-components)
                                            );
                                        apply =
                                          listMaybe:
                                          if    isNull listMaybe
                                          then  listMaybe
                                          else
                                            lib.uniqList { inputList = listMaybe; };
                                      };

                                    # NOTE: points to an existing install-path for the toolchain.
                                    # Since this is creating the toolchain, and the rust-overlay
                                    # rust-overlay probably already handles this, I'm going
                                    # to assume that this isn't needed.
                                    #
                                    # path =
                                    #   {
                                    #     inherit _type;
                                    #     default = null;
                                    #     type =
                                    #       types.nullOr
                                    #         (
                                    #           types.pathWith
                                    #             { inStore = true; absolute = true; }
                                    #         );
                                    #   };

                                    profile =
                                      {
                                        inherit _type;
                                        default = null;
                                        type =
                                          types.nullOr (types.enum rust-profiles);
                                      };

                                    # NOTE: handled through existing nixpkgs infra,
                                    # so probably not needed?
                                    #
                                    # targets =
                                    #   {
                                    #     inherit _type;
                                    #     type = types.listOf (types.enum []);
                                    #   };
                                  };
                              };
                      };
                  };
            };
        };
      }

      (
        { config, ... }:
        {
          config =
            {
              perSystem =
                { self', pkgs, ... }:
                {
                  rust-bins =
                    let
                      mkRustBins =
                        (inputs.rust-overlay or rust-overlay).lib.mkRustBin {} pkgs;

                      toolchain = config.rust.toolchain;
                      tc-config =
                        builtins.addErrorContext
                          "While evaluating `toolchain.config'"
                          toolchain.config;

                      attrName =
                        name:
                        if    isNull (tc-config.${name} or null)
                        then  null
                        else  name;

                      cfg-args =
                        {
                          ${attrName "channel"}     = tc-config.channel;
                          ${attrName "components"}  = tc-config.components;
                          # ${attrName "path"}        = tc-config.path;
                          ${attrName "profile"}     = tc-config.profile;
                          # ${attrName "targets"}     = tc-config.targets;
                        };

                      rust-bins =
                        if    toolchain ? file
                        then  mkRustBins.fromRustupToolchainFile toolchain.file
                        else  mkRustBins.fromRustupToolchain cfg-args;
                    in
                      rust-bins;

                  _module.args.rustPlatform =
                    pkgs.makeRustPlatform
                      {
                        rustc = self'.rust-bins;
                        cargo = self'.rust-bins;
                      };
                };
            };
        }
      )
    ];
}
