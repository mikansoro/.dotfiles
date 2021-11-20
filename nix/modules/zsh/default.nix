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
    initExtra = builtins.readFile ../../../files/zsh-alias.zsh + ''
      eval "$(starship init zsh)"
      [[ /home/michael/.nix-profile/bin/kubectl ]] && source <(kubectl completion zsh)
    '';
    envExtra = ''
      GDK_SCALE=1
      EDITOR=vim
      PATH=$PATH:~/.dotfiles/scripts
      PATH="$PATH:~/.krew/bin"
    '';
  };

  home.file.".config/starship.toml".source = ../../../files/starship.toml;
}
