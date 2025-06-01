{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    systems.url = "github:nix-systems/x86_64-linux";
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-checks = {
      url = "github:huuff/nix-checks";
    };
    pre-commit = {
      url = "github:cachix/git-hooks.nix";
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
      rust-overlay,
      treefmt,
      pre-commit,
      nix-checks,
      ...
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        rustPkgs = pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rust-analyzer"
            "clippy"
          ];
          targets = [
            "wasm32-unknown-unknown"
          ];
        };
        treefmt-build = (treefmt.lib.evalModule pkgs (import ./treefmt.nix { })).config.build;
        pre-commit-check = pre-commit.lib.${system}.run {
          src = ./.;
          hooks = import ./pre-commit.nix {
            inherit pkgs rustPkgs;
            treefmt = treefmt-build.wrapper;
          };
        };
        inherit (nix-checks.lib.${system}) checks;
      in
      {
        checks = {
          formatting = treefmt-build.check self;
          statix = checks.statis ./.;
          deadnix = checks.deadnix ./.;
          flake-checker = checks.flake-checker ./.;
          clippy = checks.clippy ./.;
        };

        formatter = treefmt-build.wrapper;

        devShells.default =
          with pkgs;
          mkShell {
            inherit (pre-commit-check) shellHook;
            nativeBuildInputs = [
              pkg-config
            ];

            buildInputs = [
              # nix
              nil
              nixfmt-rfc-style

              rustPkgs

              wasm-pack # to test wasm
              dioxus-cli
              wasm-bindgen-cli_0_2_100
            ];
          };
      }
    );
}
