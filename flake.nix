{
  description = "My templates for quickly bootstrapping a working environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { ... }: {

    templates = {
      rust = {
        path = ./rust;
        description = "Rust tools and rust analyzer";
      };
    };

  };
}
