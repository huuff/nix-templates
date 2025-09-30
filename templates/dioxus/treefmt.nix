{ pkgs, rustPkgs, ... }:
{
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true;
    rustfmt.enable = true;
    taplo.enable = true;
    yamlfmt.enable = true;
  };

  settings = {
    formatter = {
      dxfmt = {
        # XXX: copy-pasted this approach from the treefmt impl for packer
        # CONTRIB: add this to treefmt-nix, maybe make it better
        command = pkgs.writeShellApplication {
          name = "treefmt-nix-dx-fmt-wrapper";
          runtimeInputs = [ rustPkgs ];
          text =
            let
              dx = "${pkgs.dioxus-cli}/bin/dx";
            in
            ''
              set -eu

              for file in "$@"; do
                # we have to do this incredibly weird shit because apparently all dx fmt commands
                # modify the file (update mtime), and that will make the treefmt check mode fail
                # (in pre-commit for example).
                # so we just put the formatted output in some other file, and put it back only if we're
                # sure it's changed
                tmp="$file.FORMATTED"
                ${dx} fmt --file - <"$file" > "$tmp"
                if ! cmp -s "$file" "$tmp"; then
                  mv -f "$tmp" "$file"
                else
                  rm "$tmp"
                fi
              done

              exit "''${rc:-0}"
            '';
        };

        includes = [ "*.rs" ];
      };
    };
  };

}
