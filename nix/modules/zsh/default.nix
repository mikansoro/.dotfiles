{ config, pkgs, libs, ... }:

{
  home.packages = with pkgs; [
    krew
    kubectl
    kustomize
    kubectx
    minikube
    starship
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = builtins.readFile ../../../files/zsh/.zshrc;
    envExtra = ''
      GDK_SCALE=1
      EDITOR=emacsclient -c
      VISUAL=emacsclient -c
      PATH=$PATH:~/.dotfiles/scripts/nix-system
    '';
  };

  home.file.".config/starship.toml".source = ../../../files/starship/.config/starship.toml;
}
