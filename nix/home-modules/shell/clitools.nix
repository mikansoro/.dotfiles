{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    dig
    fd
    gnused
    htop
    jq
    ripgrep
    tmux
    tree
    whois
    yq-go
  ];

  # add git config here?
  programs.bat.enable = true;
  programs.btop.enable = true;
  programs.tmux.enable = true;
  programs.vim.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
  programs.bash.enable = true;

  xdg.configFile."starship.toml".text = (builtins.readFile ./starship.toml);
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
}