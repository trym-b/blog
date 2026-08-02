#!/usr/bin/env bash

set -e
set -u
set -o pipefail

sh <(curl -L https://nixos.org/nix/install) --daemon
nix-env --install --attr devenv -f https://github.com/NixOS/nixpkgs/tarball/nixpkgs-unstable
