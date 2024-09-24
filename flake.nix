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

        nix = {
          path = ./nix;
          description = "Nix-only (or mostly) projects with nil, nixfmt and statix";
        };
      };
    }
    // utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        treefmt-build = (treefmt.lib.evalModule pkgs ./treefmt.nix).config.build;
        pre-commit-check = pre-commit.lib.${system}.run {
          src = ./.;
          hooks = import ./pre-commit.nix {
            inherit pkgs;
            treefmt = treefmt-build.wrapper;
          };
        };
        mkCheck =
          name: code:
          pkgs.runCommand name { } ''
            cd ${./.}
            ${code}
            mkdir "$out"
          '';
      in
      {
        checks = {
          inherit pre-commit-check;

          # just check formatting is ok without changing anything
          formatting = treefmt-build.check self;

          # some of the checks are done in pre-commit hooks, but having them here allows running them
          # with all files, not just staged changes
          statix = mkCheck "statix-check" "${pkgs.statix}/bin/statix check";
          deadnix = mkCheck "deadnix-check" "${pkgs.deadnix}/bin/deadnix --fail";
        };

        # for `nix fmt`
        formatter = treefmt-build.wrapper;

        devShells.default = pkgs.mkShell {
          inherit (pre-commit-check) shellHook;
          buildInputs =
            with pkgs;
            pre-commit-check.enabledPackages
            ++ [
              nil
              nixfmt-rfc-style
            ];
        };
      }
    );

}
