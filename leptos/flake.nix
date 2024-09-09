{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, utils, rust-overlay }: 
  utils.lib.eachDefaultSystem(system: 
  let
    overlays = [ 
      (import rust-overlay) 
      (self: super: {
        leptosfmt = self.rustPlatform.buildRustPackage rec {
          pname = "leptosfmt";
          version = "0.1.30";

          src = self.fetchCrate {
            inherit version;
            crateName = pname;
            hash = "sha256-BSWU4KjEfbs8iDkCq+n2D34WS9kqKCVePKnghgQQb/0=";
          };

          cargoHash = "sha256-ZhzcrjVLdR7V6ylmZrQJAFFOL6hSuiORA3iNQdSXEzA=";

          meta = {
            description = "A formatter for the leptos view! macro";
            mainProgram = "leptosfmt";
            homepage = "https://github.com/bram209/leptosfmt";
            changelog = "https://github.com/bram209/leptosfmt/blob/${version}/CHANGELOG.md";
            license = with self.lib.licenses; [asl20 mit];
          };
        };
      })
    ];
    pkgs = import nixpkgs { inherit system overlays; };
  in
  {
    devShell = with pkgs; mkShell {
      buildInputs = [ 
        (rust-bin.stable.latest.default.override {
          targets = [
            "x86_64-unknown-linux-musl"
            "wasm32-unknown-unknown"
          ];
        })
        rust-analyzer

        cargo-leptos
        cargo-generate # required for cargo-leptos
        dart-sass
        binaryen # required for release compilation
        leptosfmt
        stylance-cli
      ];
    };
  });
}
