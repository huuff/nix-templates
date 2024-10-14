{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/x86_64-linux";
    utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs = { nixpkgs, utils }:
  utils.lib.eachDefaultSystem(system:
  let 
    pkgs = import nixpkgs { inherit system; };
  in {

    devShell = with pkgs; mkShell {
      buildInputs = [texlive.combined.scheme-full];
    };
  });
}

