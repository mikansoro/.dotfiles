# mikansoro/.dotfiles 

My collection of dotfiles and configs for both work and home. 

Currently in the process of moving back to nix for configurations. Started with my work-mac using `nix-darwin`, but also using nix for several VMs, and eventually my personal desktop/laptop. Nix directory is in a lot of flux due to rapid development. trying to make a flake that can accomodate multiple systems and system architectures. 

## Notable directories
- Zsh: configuration is in `nix/home-modules/shell/`
- Emacs: doom-emacs via nix flake. `nix/home-modules/emacs/`
- per host configuration in `nix/hosts`
