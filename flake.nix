{
  description = "My templates for quickly bootstrapping a working environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    pre-commit.url = "github:cachix/git-hooks.nix";
    treefmt.url = "github:numtide/treefmt-nix";
    systems.url = "github:nix-systems/x86_64-linux";
    utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      pre-commit,
      treefmt,
      ...
    }:
    {

      templates = {
        rust = {
          path = ./rust;
          description = "Rust tools and rust analyzer";
        };
        leptos = {
          path = ./leptos;
          description = "Rust tools, rust analyzer, sass, wasm and leptos tooling";
        };
      };
    }
    // utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        treefmtEval = treefmt.lib.evalModule pkgs ./treefmt.nix;
      in
      {
        checks = {
          pre-commit-check = pre-commit.lib.${system}.run {
            src = ./.;
            # TODO configure more hooks
            hooks = {
              nix-fmt = {
                name = "Nix fmt";
                enable = true;
                entry = "${treefmtEval.config.build.wrapper}/bin/treefmt";
                pass_filenames = false;
              };
            };
          };
          formatting = treefmtEval.config.build.check self;
        };

        formatter = treefmtEval.config.build.wrapper;

        devShells = {
          default = nixpkgs.legacyPackages.${system}.mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;
            buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
          };
        };
      }
    );

}
