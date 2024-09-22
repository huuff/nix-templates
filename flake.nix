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
      in
      {
        checks = {
          pre-commit-check = pre-commit.lib.${system}.run {
            src = ./.;
            hooks = {
              check-merge-conflicts.enable = true;
              check-added-large-files.enable = true;
              commitizen.enable = true;

              gitleaks = {
                name = "gitleaks";
                enable = true;
                entry = "${pkgs.gitleaks}/bin/gitleaks detect";
                stages = [ "pre-commit" ];
              };

              treefmt = {
                enable = true;
                packageOverrides.treefmt = treefmt-build.wrapper;
              };

              statix.enable = true;
              deadnix.enable = true;
              nil.enable = true;
              flake-checker.enable = true;

              actionlint.enable = true;

              markdownlint.enable = true;
              typos.enable = true;
            };
          };

          # just check formatting is ok without changing anything
          formatting = treefmt-build.check self;
        };

        # for `nix fmt`
        formatter = treefmt-build.wrapper;

        devShells.default = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs =
            with pkgs;
            self.checks.${system}.pre-commit-check.enabledPackages
            ++ [
              nil
              nixfmt-rfc-style
            ];
        };
      }
    );

}
