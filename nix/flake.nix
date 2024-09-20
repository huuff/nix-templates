{
  description = "Template for Nix project";

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
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        treefmtEval = treefmt.lib.evalModule pkgs ./treefmt.nix;
      in
      {
        checks = {
          pre-commit-check = pre-commit.lib.${system}.run {
            src = ./.;
            hooks = {
              gitleaks = {
                name = "gitleaks";
                enable = true;
                entry = "${pkgs.gitleaks}/bin/gitleaks detect";
                stages = [ "pre-commit" ];
              };

              treefmt = {
                enable = true;
                packageOverrides.treefmt = treefmtEval.config.build.wrapper;
              };

              statix.enable = true;
              deadnix.enable = true;
              nil.enable = true;
            };
          };

          # just check formatting is ok without changing anything
          formatting = treefmtEval.config.build.check self;
        };

        # for `nix fmt`
        formatter = treefmtEval.config.build.wrapper;

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
