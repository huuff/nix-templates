# Nix Templates

Templates to quickly bootstrap a project with:

* Appropriate tooling (build system, LSP, formatters, etc.)
* Sensible pre-commit hooks
* Basic github actions
* Flake checks

Just call `nix flake new --template github:huuff/nix-templates#«template»`

The available ones are:

* `rust`: including stable toolchain, clippy, rustfmt, rust-analyzer, linux target.
* `leptos`: everything in `rust`, plus wasm target, cargo-leptos,
leptosfmt, stylance, sass and binaryen.
* `nix`: for nix-only projects, including nil, nixfmt, statix and deadnix.
