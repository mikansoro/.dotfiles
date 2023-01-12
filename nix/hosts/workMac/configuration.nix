{ config, pkgs, lib, ... }:

{

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '';

  fonts.fontsDir.enable = true;

  homebrew = {
    enable = true;
    brews = [
      {
        name = "superbrothers/opener/opener";
        start_service = true;
        restart_service = true;
      }
      "hyperkit"
      # cloudquery
    ];
    casks = [
      "spotify"
      "iterm2"
    ];
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
