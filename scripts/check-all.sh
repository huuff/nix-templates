#!/usr/bin/env bash
set -euo pipefail

# cd to the root dir
cd "$(git rev-parse --show-toplevel)"

for template in ./templates/*/; do
    echo "Checking $template..."
    nix flake check "$template"
done
