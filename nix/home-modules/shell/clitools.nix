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
    yq-go
  ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [
    whois
  ];

  # shell history in sqlite
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      update_check = false;
      auto_sync = true;
      sync_address = "https://atuin.lavaridge.k8s.mikansystems.com";
      sync_frequency = "5m";
      secrets_filter = true;
    };
  };

  # shell tools
  programs.bat.enable = true;
  programs.btop.enable = true;
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    mouse = true;
    shell = "${pkgs.zsh}/bin/zsh";
  };

  programs.vim.enable = true;
  programs.bash.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  # starship
  xdg.configFile."starship.toml".text = (builtins.readFile ./starship.toml);
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
}
