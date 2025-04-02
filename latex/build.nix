{ pkgs, latex, ... }:
pkgs.stdenvNoCC.mkDerivation {
  name = "latex-pdf";
  src = ./.;

  buildInputs = [ latex ];

  buildPhase = ''
    pdflatex -jobname=output *.tex
  '';

  installPhase = ''
    mkdir -p $out
    cp output.pdf $out/
  '';
}
