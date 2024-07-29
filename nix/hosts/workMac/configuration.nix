{ config, pkgs, lib, ... }:

{

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  nix.extraOptions = ''
    auto-optimise-store = false
    experimental-features = nix-command flakes
  '';

  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    emacsPackages.nerd-icons
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  homebrew = {
    # NOTE: Temporarily disable homebrew integration until i can remove the old binaries
    enable = false;
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
