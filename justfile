# Justfile for mikansoro dotfiles

hostname := `hostname -s`

update-private:
    nix flake update nix-private

update-all:
    nix flake update

deploy-only:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ "$(uname)" == "Darwin" ]]; then
        #sudo darwin-rebuild switch --flake .#{{hostname}}
        sudo darwin-rebuild switch --flake .#workMac
    else
        sudo nixos-rebuild switch --flake .#{{hostname}}
    fi

deploy: update-private deploy-only
