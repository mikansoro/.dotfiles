{ config, pkgs, lib, ... }:

{

  users.users."michael.rowland" = {
    name = "michael.rowland";
    home = "/Users/michael.rowland";
    shell = lib.mkDefault pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # https://github.com/DeterminateSystems/nix-installer/issues/234
  # Determinite Systems Installer doesn't add a nix channel, so nix-shell doesn't work
  # adding extra-nix-path fixes it
  nix.extraOptions = ''
    auto-optimise-store = false
    experimental-features = nix-command flakes
    extra-nix-path = nixpkgs=flake:nixpkgs
  '';

  nix.enable = true;
  nix.channel.enable = false;

  system.primaryUser = "michael.rowland";

  #fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [
    ibm-plex
    source-code-pro
    source-sans-pro
    source-serif-pro
    noto-fonts-cjk-sans
    source-han-sans
    source-han-serif
    source-han-code-jp
    emacsPackages.nerd-icons
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  home-manager.backupFileExtension = "hmbak";
  
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
  # nix.package = pkgs.nix;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina

  nix.settings.trusted-substituters = [ "https://cache.flox.dev" ];
  nix.settings.trusted-public-keys = [ "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs=" ];

  # workaround for a single user system: https://github.com/LnL7/nix-darwin/pull/252#issuecomment-731083818
  # emacs doesn't handle $USER or $HOME expansion in PATH, so even when the path is set via launchd packages
  # installed via homeassistant aren't found. Have to replace the variables to be static before the PATH is
  # set, otherwise emacs won't load additional packages from path (ie ripgrep, language servers)
  launchd.user.envVariables.PATH = (lib.replaceStrings ["$HOME" "$USER"]
    [config.users.users."michael.rowland".home config.users.users."michael.rowland".name]
    config.environment.systemPath);

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
