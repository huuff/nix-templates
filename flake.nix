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
      leptos = {
        path = ./leptos;
        description = "Rust tools, rust analyzer, sass, wasm and leptos tooling";
      };
    };

  };
}
