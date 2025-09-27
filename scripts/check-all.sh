#!/usr/bin/env bash
set -euo pipefail

# cd to the root dir
cd "$(git rev-parse --show-toplevel)"

find ./templates -mindepth 1 -maxdepth 1 -type d -exec nix flake check {} \;
