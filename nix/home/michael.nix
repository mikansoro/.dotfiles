{ config, pkgs, ... }:

# let
#   unstable = import <nixpkgs-unstable> { config.allowUnfree = true; };
# in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "michael";
  home.homeDirectory = "/home/michael";

  home.packages = with pkgs; [
    wally-cli

    mpv
    ffmpeg
    youtube-dl 
    plex-media-player
    plexamp
    spotify
    unstable.discord
    syncplay

    unstable.steam
    unstable.steam-run
    # unstable.steam-tui
    unstable.steamPackages.steamcmd
    
    thunderbird
    unstable._1password-gui
    unstable._1password
    unstable.signal-desktop

    barrier
    neofetch 

    vulkan-tools

    ipmitool
  ];

  programs.git = {
    enable = true;
    userName = "Michael Rowland";
    userEmail = "michael@mikansystems.com";
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
