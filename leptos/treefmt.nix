_: {
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true;
    rustfmt.enable = true;
    taplo.enable = true;
    yamlfmt.enable = true;
    leptosfmt.enable = true;
  };
}
