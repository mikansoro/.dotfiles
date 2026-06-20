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

boot-only:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ "$(uname)" == "Darwin" ]]; then
        #sudo nixos-rebuild boot --flake .#{{hostname}}
        sudo nixos-rebuild boot --flake .#workMac
    else
        sudo nixos-rebuild boot --flake .#{{hostname}}
    fi

boot: update-private boot-only
