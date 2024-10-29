{
  description = "My templates for quickly bootstrapping a working environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    pre-commit.url = "github:cachix/git-hooks.nix";
    treefmt.url = "github:numtide/treefmt-nix";
    systems.url = "github:nix-systems/x86_64-linux";
    nix-checks = {
      url = "github:huuff/nix-checks";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      nix-checks,
      treefmt,
      ...
    }:
    {
      templates = {
        rust = {
          path = ./rust;
          description = "Rust tools and rust analyzer";
          welcomeText = ''
            # Rust template

            The template has been installed! You can now run `cargo init .` to create your cargo project. Some alternatives are:
            * `cargo init . --lib` for a library project.
            * `cargo init . --bin` for a binary project.
          '';
        };

        leptos = {
          path = ./leptos;
          description = "Rust tools, rust analyzer, sass, wasm and leptos tooling";
        };

        # pretty much a copy-paste of this
        nix = {
          path = ./nix;
          description = "Nix-only (or mostly) projects with nil, nixfmt and statix";
        };

        latex = {
          path = ./latex;
          description = "For quickly authoring latex docs";
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
        inherit (nix-checks.lib.${system}) checks;
      in
      {
        checks = {
          # just check formatting is ok without changing anything
          formatting = treefmt-build.check self;
          statix = checks.statix ./.;
          deadnix = checks.deadnix ./.;
          flake-checker = checks.flake-checker ./.;
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
