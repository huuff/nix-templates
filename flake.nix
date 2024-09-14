{
  description = "My templates for quickly bootstrapping a working environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
    systems.url = "github:nix-systems/x86_64-linux";
    utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs = { self, nixpkgs, utils, pre-commit-hooks, ... }: {

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
  } // utils.lib.eachDefaultSystem (system: {
    checks = {
      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixpkgs-fmt.enable = true;
        };
      };
    };

    devShells = {
      default = nixpkgs.legacyPackages.${system}.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
      };
    };
  });

}
