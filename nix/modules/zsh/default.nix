{ config, pkgs, libs, ... }:

{
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
    '';
  };

  home.file.".config/starship.toml".source = ../../../files/starship.toml;
}
